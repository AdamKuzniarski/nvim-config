local M = {}

function M.setup(ls)
	local s = ls.snippet
	local t = ls.text_node
	local i = ls.insert_node

	local function r3f_mesh()
		return s({ trig = "r3fmesh", name = "R3F mesh", dscr = "Mesh with geometry and material" }, {
			t({ "<mesh>", "  <" }),
			i(1, "boxGeometry"),
			t({ " />", "  <" }),
			i(2, "meshStandardMaterial"),
			t(' color="'),
			i(3, "orange"),
			t({ '" />', "</mesh>" }),
			i(0),
		})
	end

	local function three_mesh()
		return s({ trig = "threemesh", name = "Three.js mesh", dscr = "Mesh using the THREE namespace" }, {
			t("const "),
			i(1, "mesh"),
			t({ " = new THREE.Mesh(", "  new THREE." }),
			i(2, "BoxGeometry"),
			t({ "(),", "  new THREE." }),
			i(3, "MeshStandardMaterial"),
			t('({ color: "'),
			i(4, "orange"),
			t({ '" })', ");" }),
			i(0),
		})
	end

	local function three_start()
		return s({
			trig = "threestart",
			name = "Three.js starter",
			dscr = "Browser-only JS/TS entry file with a rotating box; use in an empty file",
			show_condition = function(line_to_cursor)
				local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				return #lines == 1 and lines[1] == line_to_cursor and not line_to_cursor:find("%s")
			end,
		}, {
			t({
				'import * as THREE from "three";',
				"",
				"const scene = new THREE.Scene();",
				"const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 100);",
				"camera.position.z = 3;",
				"",
				"const renderer = new THREE.WebGLRenderer({ antialias: true });",
				"renderer.setSize(window.innerWidth, window.innerHeight);",
				'document.body.style.margin = "0";',
				'renderer.domElement.style.display = "block";',
				"document.body.appendChild(renderer.domElement);",
				"",
				"const box = new THREE.Mesh(",
				"  new THREE.BoxGeometry(),",
				"  new THREE.MeshBasicMaterial({ color: ",
			}),
			i(1, "0x44aa88"),
			t({
				" })",
				");",
				"scene.add(box);",
				"",
				'window.addEventListener("resize", () => {',
				"  const width = window.innerWidth;",
				"  const height = window.innerHeight;",
				"  camera.aspect = width / height;",
				"  camera.updateProjectionMatrix();",
				"  renderer.setSize(width, height);",
				"});",
				"",
				"renderer.setAnimationLoop((time) => {",
				"  box.rotation.x = time / 2000;",
				"  box.rotation.y = time / 1000;",
				"  renderer.render(scene, camera);",
				"});",
			}),
			i(0),
		})
	end

	local function three_loop()
		return s({ trig = "threeloop", name = "Three.js render loop", dscr = "Render an existing scene and camera" }, {
			t({ "renderer.setAnimationLoop((time) => {", "  " }),
			i(1),
			t({ "", "  renderer.render(scene, camera);", "});" }),
			i(0),
		})
	end

	local function three_orbit()
		return s({
			trig = "threeorbit",
			name = "Three.js OrbitControls",
			dscr = "Orbit camera; import OrbitControls separately",
		}, {
			t({ "const controls = new OrbitControls(camera, renderer.domElement);", "controls.update();" }),
			i(0),
		})
	end

	local function three_resize()
		return s({
			trig = "threeresize",
			name = "Three.js resize",
			dscr = "Resize an existing renderer and perspective camera",
		}, {
			t({
				"function resizeRenderer() {",
				"  const canvas = renderer.domElement;",
				"  const width = canvas.clientWidth;",
				"  const height = canvas.clientHeight;",
				"  if (width === 0 || height === 0) return;",
				"  renderer.setSize(width, height, false);",
				"  camera.aspect = width / height;",
				"  camera.updateProjectionMatrix();",
				"}",
				"",
				'window.addEventListener("resize", resizeRenderer);',
				"resizeRenderer();",
			}),
			i(0),
		})
	end

	local function gui_slider()
		return s({
			trig = "guislider",
			name = "lil-gui slider",
			dscr = "Numeric controller with range, step, and label; import GUI separately",
		}, {
			i(1, "gui"),
			t({ "", "  .add(" }),
			i(2, "floor.material"),
			t(', "'),
			i(3, "displacementBias"),
			t({ '")', "  .min(" }),
			i(4, "-1"),
			t({ ")", "  .max(" }),
			i(5, "1"),
			t({ ")", "  .step(" }),
			i(6, "0.001"),
			t({ ")", '  .name("' }),
			i(7, "floor displacementBias"),
			t('");'),
			i(0),
		})
	end

	for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
		local snippets = { three_mesh(), three_loop(), three_orbit(), three_resize() }
		if ft == "javascript" or ft == "typescript" then
			table.insert(snippets, three_start())
			table.insert(snippets, gui_slider())
		end
		if ft == "javascriptreact" or ft == "typescriptreact" then
			table.insert(snippets, r3f_mesh())
		end
		ls.add_snippets(ft, snippets)
	end
end

return M
