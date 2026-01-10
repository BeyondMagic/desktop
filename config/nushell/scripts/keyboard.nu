# Manager of the main reader of mozc.
export module manager {

	# Open configuration tool.
	export def configuration [
	] -> nothing {
		^/usr/lib/mozc/mozc_tool '--mode=config_dialog'
	}

	export def handwriting [
	] -> nothing {
		^/usr/lib/mozc/mozc_tool --mode=hand_writing
	}
}

