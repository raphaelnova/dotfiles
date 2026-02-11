vim.filetype.add({
	pattern = {
		[".*/git/config"] = "gitconfig",
		[".*/.?ssh/config"] = "sshconfig",
	},
	filename = {
		["Vagrantfile"] = "ruby",
		[".bashrc"] = "bash",
		[".bash_profile"] = "bash",
		[".prettierrc"] = "yaml",
	},
	extension = {
		cypher = "cypher",
		cql = "cypher",
		cyp = "cypher",
	},
})
