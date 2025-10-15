package build

#regexManager: {
	customType: "regex"
	fileMatch: [...string]
	matchStrings: [...string]
	matchStringsStrategy?: string
	depNameTemplate?:      string
	versioningTemplate?:   string
	datasourceTemplate?:   string
	registryUrlTemplate?:  string
	packageNameTemplate?:  string
}

_githubReleaseManager: #regexManager & {
	fileMatch: [
		"^(.*?).md$",
	]
	matchStrings: ["https://github.com/(?<depName>.*?)/releases/download/(?<currentValue>.*?)/"]
	datasourceTemplate: "github-releases"
	versioningTemplate: "semver-coerced"
}

labels: [
	"dependencies",
	"renovate",
]
extends: [
	"config:best-practices",
]
dependencyDashboard:   true
semanticCommits:       "enabled"
rebaseWhen:            "auto"
branchConcurrentLimit: 0
prConcurrentLimit:     0
prHourlyLimit:         0
"github-actions": enabled: false
digest: enabled:           false
customManagers: [
	_githubReleaseManager,
	{
		customType: "regex"
		fileMatch: [
			"^(.*?).cue$",
		]
		matchStrings: [
			"uses: \"(?<depName>.*?)@(?<currentValue>.*?)\"",
		]
		datasourceTemplate: "github-tags"
		versioningTemplate: "semver-coerced"
	},
	{
		fileMatch: [
			"^(.*?)cue.mod/module.cue$",
		]
		matchStrings: [
			"version: \"(?<currentValue>.*?)\"",
			"Language: &modfile.Language{\n(\t*)Version: \"(?<currentValue>.*?)\",\n(\t*)}",
		]
		depNameTemplate:    "cue-lang/cue"
		datasourceTemplate: "github-releases"
		versioningTemplate: "semver-coerced"
	},
	{
		customType: "regex"
		fileMatch: [
			"build/workflows.cue",
		]
		matchStrings: [#"uses: "(?<depName>.*?)@(?<currentDigest>.*?)" // (?<currentValue>.*?)(\s|$)"#]
		datasourceTemplate: "github-tags"
		versioningTemplate: "semver-coerced"
	},
]
