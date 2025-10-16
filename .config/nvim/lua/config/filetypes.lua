vim.filetype.add({
	pattern = {
		[".*/git/config"] = "gitconfig",
		[".*/.?ssh/config"] = "sshconfig",
	},
	filename = {
		["Vagrantfile"] = "ruby",
	},
	extension = {
		cypher = "cypher",
		cql = "cypher",
		cyp = "cypher",
	},
})
