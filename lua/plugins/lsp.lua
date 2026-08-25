return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			vim.lsp.config("vtsls", {
				settings = {
					typescript = {
						inlayHints = {
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							variableTypes = { enabled = false },
							propertyDeclarationTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = true },
						},
					},
					javascript = {
						inlayHints = {
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							variableTypes = { enabled = false },
							propertyDeclarationTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = true },
						},
					},
				},
			})

			vim.lsp.config("tailwindcss", {
				root_dir = function(bufnr, on_dir)
					local root = vim.fs.root(bufnr, {
						"tailwind.config.js",
						"tailwind.config.cjs",
						"tailwind.config.mjs",
						"tailwind.config.ts",
						"package.json",
					})
					if root then
						on_dir(root)
					end
				end,
				workspace_required = true,
				settings = {
					tailwindCSS = {
						validate = true,
						classAttributes = {
							"class",
							"className",
							"class:list",
							"classList",
							"ngClass",
						},
						classFunctions = {
							"clsx",
							"cn",
							"cva",
							"tw",
						},
					},
				},
			})

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						validate = { enable = true },
					},
				},
			})

			vim.lsp.config("html", {
				filetypes = { "html" },
			})

			vim.lsp.config("cssls", {
				settings = {
					css = { validate = true },
					scss = { validate = true },
					less = { validate = true },
				},
			})

			vim.lsp.config("intelephense", {
				root_markers = { "theme.json", "style.css", "composer.json", ".git" },
				settings = {
					intelephense = {
						format = { enable = true },
						files = {
							maxSize = 5000000,
						},
						stubs = {
							"apache",
							"bcmath",
							"bz2",
							"calendar",
							"com_dotnet",
							"Core",
							"ctype",
							"curl",
							"date",
							"dba",
							"dom",
							"enchant",
							"fileinfo",
							"filter",
							"fpm",
							"ftp",
							"gd",
							"hash",
							"iconv",
							"imap",
							"intl",
							"json",
							"ldap",
							"libxml",
							"mbstring",
							"mcrypt",
							"mysqli",
							"oci8",
							"odbc",
							"openssl",
							"pcntl",
							"pcre",
							"PDO",
							"pdo_ibm",
							"pdo_mysql",
							"pdo_pgsql",
							"pdo_sqlite",
							"pgsql",
							"Phar",
							"posix",
							"pspell",
							"readline",
							"Reflection",
							"session",
							"shmop",
							"SimpleXML",
							"snmp",
							"soap",
							"sockets",
							"sodium",
							"SPL",
							"sqlite3",
							"standard",
							"superglobals",
							"sysvmsg",
							"sysvsem",
							"sysvshm",
							"tidy",
							"tokenizer",
							"xml",
							"xmlreader",
							"xmlrpc",
							"xmlwriter",
							"xsl",
							"Zend OPcache",
							"zip",
							"zlib",
							"wordpress",
							"woocommerce",
							"acf-pro",
						},
					},
				},
			})

			vim.lsp.config("sourcekit", {
				cmd = { "sourcekit-lsp" },
				filetypes = { "swift" },
				root_markers = { "Package.swift", ".git" },
				capabilities = vim.tbl_deep_extend("force", capabilities, {
					workspace = {
						didChangeWatchedFiles = {
							dynamicRegistration = true,
						},
					},
				}),
			})

			vim.lsp.enable({
				"lua_ls",
				"vtsls",
				"tailwindcss",
				"jsonls",
				"html",
				"cssls",
				"intelephense",
				"marksman",
				"prismals",
				"sourcekit",
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, {
							buffer = event.buf,
							desc = "LSP: " .. desc,
						})
					end

					map("gd", vim.lsp.buf.definition, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gr", vim.lsp.buf.references, "References")
					map("gi", vim.lsp.buf.implementation, "Implementation")
					map("K", vim.lsp.buf.hover, "Hover docs")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					end
				end,
			})
		end,
	},
}
