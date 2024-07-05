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
	uses: "actions/checkout@v4.1.7"
	with?: {
		[string]: string | number | bool
		token:    "${{ secrets.PAT }}"
	}
}

#step: {
	name?: string
	run?:  string
	uses?: string
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
						uses: "actions/setup-python@v5"
						with: "python-version": "3.x"
					},
					#step & {
						run: #"echo "cache_id=$(date --utc '+%V')" >> $GITHUB_ENV"#
					},
					#step & {
						uses: "actions/cache@v4"
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
						uses: "renovatebot/github-action@v40.2.0"
						env: {
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
]
