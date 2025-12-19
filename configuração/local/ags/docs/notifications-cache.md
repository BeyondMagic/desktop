# Notification cache

Notifications handled by `widget/notification/index.tsx` are now persisted under
`$XDG_CACHE_HOME/notifications`. The helper in `widget/notification/storage.ts`
creates the following structure on demand:

```
notifications/
├── notifications.json  # append-only log of notification metadata
├── images/             # copied image assets for historical previews
└── sounds/             # copied sound files referenced by notifications
```

Each entry in `notifications.json` contains the summary, body, timestamps,
application metadata, urgency, action labels, and file paths (if any) of media
that were copied into the cache. Absolute image or sound paths from the
notification are copied into their respective folders to prevent the original
files from disappearing when the desktop entry cleans up temporary assets.

The helper intentionally stores icon or sound *names* when only themed assets
are provided. This keeps the log useful even when the caller did not provide a
file path. In case of write failures we simply log the error with `printerr`
without interrupting the notification flow.

At the moment the cache grows indefinitely, which is acceptable for the initial
implementation. Future work can add rotation policies or a user-facing browser
for the stored history.
