-- Automatic indentation style detection for opened file.
return {
	'nmac427/guess-indent.nvim',
	config = function() require('guess-indent').setup {} end,
}
