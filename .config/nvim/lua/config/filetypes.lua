vim.filetype.add({
	pattern = {
		[".*/git/config"] = "gitconfig",
		[".*/.?ssh/config"] = "sshconfig",
	},
	filename = {
		["Vagrantfile"] = "ruby",
		[".bashrc"] = "bash",
		[".bash_profile"] = "bash",
	},
	extension = {
		cypher = "cypher",
		cql = "cypher",
		cyp = "cypher",
	},
})
