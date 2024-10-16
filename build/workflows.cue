package build

import "github.com/kharf/cuepkgs/modules/github@v0"

#workflow: {
	_name: string
	workflow: github.#Workflow & {
		name:        _name
		permissions: _ | *"read-all"
		jobs: [string]: {
			"runs-on": "ubuntu-latest"
			steps: [
				#checkoutCode,
				...,
			]
		}
	}
	...
}

#checkoutCode: {
	name: "Checkout code"
	uses: "actions/checkout@eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871" // v4.2.1
	with?: {
		[string]: string | number | bool
		token:    "${{ secrets.PAT }}"
		ref?:     string
	}
}

#step: {
	name?:                string
	run?:                 string
	uses?:                string
	"working-directory"?: string
	env?: {
		[string]: string | number | bool
	}
	with?: {
		[string]: string | number | bool
	}
}

workflows: [
	#workflow & {
		_name: "deploy"
		workflow: github.#Workflow & {
			permissions: contents: "write"
			on: {
				push: {
					branches: [
						"main",
					]
					"paths-ignore": [
						".github/**",
						"build/**",
						"renovate.json",
						".gitignore",
						"LICENSE",
					]
				}
			}

			jobs: "\(_name)": {
				steps: [
					#checkoutCode,
					#step & {
						name: "Configure Git Credentials"
						run: """
						git config user.name github-actions[bot]
						git config user.email 41898282+github-actions[bot]@users.noreply.github.com
						"""
					},
					#step & {
						uses: "actions/setup-python@f677139bbe7f9c59b41e40162b753c062f5d49a3" // v5.2.0
						with: "python-version": "3.x"
					},
					#step & {
						run: #"echo "cache_id=$(date --utc '+%V')" >> $GITHUB_ENV"#
					},
					#step & {
						uses: "actions/cache@3624ceb22c1c5a301c8db4169662070a689d9ea8" // v4.1.1
						with: {
							key:            "mkdocs-material-${{ env.cache_id }}"
							path:           ".cache"
							"restore-keys": "mkdocs-material-"
						}
					},
					#step & {
						run: "pip install mkdocs-material"
					},
					#step & {
						run: "mkdocs gh-deploy --force"
					},
				]
			}
		}
	},
	#workflow & {
		_name: "update"
		workflow: github.#Workflow & {
			on: {
				workflow_dispatch: null
				schedule: [{
					cron: "0 5 * * 1-5"
				},
				]
			}

			jobs: "\(_name)": {
				steps: [
					#checkoutCode,
					#step & {
						name: "Update"
						uses: "renovatebot/github-action@80eaf969abf68ad62aa94d9ab392421b31621634" // v40.3.4
						env: {
							LOG_LEVEL:             "debug"
							RENOVATE_REPOSITORIES: "${{ github.repository }}"
						}
						with: {
							configurationFile: "renovate.json"
							token:             "${{ secrets.PAT }}"
						}
					},
				]
			}
		}
	},
	#workflow & {
		_name: "genworkflows"
		workflow: github.#Workflow & {
			permissions: contents: "write"
			on: {
				"pull_request": {
					branches: [
						"main",
					]
				}
			}

			jobs: "\(_name)": {
				steps: [
					#checkoutCode & {
						with: {
							ref: "${{ github.head_ref || github.ref_name }}"
						}
					},
					#step & {
						uses: "cue-lang/setup-cue@a93fa358375740cd8b0078f76355512b9208acb1" //v1.0.0
						with: {
							version: "v0.9.2"
						}
					},
					#step & {
						name:                "Gen Workflows"
						"working-directory": "build"
						env: {
							CUE_REGISTRY: "ghcr.io/kharf"
						}
						run: """
						cue cmd genyamlworkflows
						git config --global user.name "Declcd Bot"
						git config --global user.email "kevinfritz210@gmail.com"
						git remote set-url origin https://${{ secrets.PAT }}@github.com/kharf/declcd-website.git
						git add ../.github/workflows
						git commit -m "chore: update yaml workflows" || true
						git push || true
						"""
					},
				]
			}
		}
	},
]
