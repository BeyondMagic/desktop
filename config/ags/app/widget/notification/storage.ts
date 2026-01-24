import GLib from "gi://GLib"
import Gio from "gi://Gio"
import AstalNotifd from "gi://AstalNotifd"

type PersistedAction = {
	id: string
	label: string
}

export type PersistedNotification = {
	id: number
	time: number
	appName: string
	appIcon?: string | null
	desktopEntry?: string | null
	summary: string
	body?: string | null
	category?: string | null
	urgency: number
	imagePath?: string | null
	imageIcon?: string | null
	soundPath?: string | null
	soundName?: string | null
	actions: PersistedAction[]
}

const cacheRoot = GLib.build_filenamev([GLib.get_user_cache_dir(), "notifications"])
const imagesDir = GLib.build_filenamev([cacheRoot, "images"])
const soundsDir = GLib.build_filenamev([cacheRoot, "sounds"])
const dataFile = GLib.build_filenamev([cacheRoot, "notifications.json"])

type PersistedListener = (notifications: PersistedNotification[]) => void
const listeners = new Set<PersistedListener>()

let dirsReady = false

function ensureDirectories() {
	if (dirsReady) return
	for (const dir of [cacheRoot, imagesDir, soundsDir]) {
		try {
			GLib.mkdir_with_parents(dir, 0o755)
		} catch (error) {
			printerr(`Failed to create cache directory ${dir}: ${error}`)
		}
	}
	dirsReady = true
}

function uniqueFilename(prefix: string, sourcePath: string) {
	const timestamp = GLib.DateTime.new_now_local()?.format("%Y%m%d%H%M%S") ?? `${Date.now()}`
	const basename = GLib.path_get_basename(sourcePath)
	return `${prefix}-${timestamp}-${basename}`
}

function copyBinaryAsset(sourcePath: string | null, targetDir: string, prefix: string) {
	if (!sourcePath) return null
	if (!GLib.path_is_absolute(sourcePath)) return null
	if (!GLib.file_test(sourcePath, GLib.FileTest.EXISTS)) return null

	ensureDirectories()

	const filename = uniqueFilename(prefix, sourcePath)
	const destinationPath = GLib.build_filenamev([targetDir, filename])

	try {
		const source = Gio.File.new_for_path(sourcePath)
		const destination = Gio.File.new_for_path(destinationPath)
		source.copy(destination, Gio.FileCopyFlags.OVERWRITE, null, null)
		return destinationPath
	} catch (error) {
		printerr(`Failed to store binary asset ${sourcePath}: ${error}`)
		return null
	}
}

function readPersisted(): PersistedNotification[] {
	ensureDirectories()
	if (!GLib.file_test(dataFile, GLib.FileTest.EXISTS)) return []
	try {
		const [, contents] = GLib.file_get_contents(dataFile)
		if (!contents) return []
		const text = new TextDecoder().decode(contents as Uint8Array)
		return JSON.parse(text) as PersistedNotification[]
	} catch (error) {
		printerr(`Failed to read persisted notifications: ${error}`)
		return []
	}
}

function savePersisted(entries: PersistedNotification[]) {
	try {
		GLib.file_set_contents(dataFile, JSON.stringify(entries, null, 2))
	} catch (error) {
		printerr(`Failed to save notifications history: ${error}`)
	}
}

function emitPersisted(entries: PersistedNotification[]) {
	for (const listener of listeners) {
		try {
			listener(entries)
		} catch (error) {
			printerr(`Persisted notifications listener error: ${error}`)
		}
	}
}

export function getPersistedNotifications() {
	return readPersisted()
}

export function subscribeToPersistedNotifications(listener: PersistedListener) {
	listeners.add(listener)
	return () => listeners.delete(listener)
}

export function persistNotification(notification: AstalNotifd.Notification) {
	if (!notification) return
	ensureDirectories()

	const existing = readPersisted()
	if (existing.some((entry) => entry.id === notification.id)) {
		print(`Notification with ID ${notification.id} already persisted, skipping.`)
		return
	}

	const imagePath = copyBinaryAsset(notification.image ?? null, imagesDir, `image-${notification.id}`)
	const soundPath = copyBinaryAsset(notification.soundFile ?? null, soundsDir, `sound-${notification.id}`)

	const entry: PersistedNotification = {
		id: notification.id,
		time: notification.time,
		appName: notification.appName,
		appIcon: notification.appIcon,
		desktopEntry: notification.desktopEntry,
		summary: notification.summary,
		body: notification.body,
		category: notification.category,
		urgency: notification.urgency,
		imagePath,
		imageIcon: imagePath ? null : notification.image,
		soundPath,
		soundName: soundPath ? null : notification.soundName,
		actions: notification.actions.map((action) => ({
			id: action.id,
			label: action.label,
		})),
	}

	existing.unshift(entry)
	savePersisted(existing)
	emitPersisted(existing)
}