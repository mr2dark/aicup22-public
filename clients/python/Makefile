# Local runner host
HOST ?= 127.0.0.1
# Start port for agent to use
START_PORT ?= 31001
# A random seed for a game
SEED ?= null
# Round configuration
ROUND ?= Round1
# Max number of player slots
SLOTS ?= 6
DEBUG ?= 0

export RUST_BACKTRACE := full

# The path to a built agent binary (relative to the current folder)
RELEASE_PATH ?= target/release/aicup2020
RUN_COMMAND ?= pipenv run python main.py
# The path to a local runner binary (absolute or relative to the current folder)
RUNNER_PATH ?= ../../app-macos/aicup22
# The path to a built versions binaries (relative to the current folder)
VERSIONS_PATH ?= releases
VERSIONS_PREFIX ?= mr2dark_

#archive_contents := $(shell find . "(" -not -path "./target/**" ")" -and "(" -name "*.rs" -or -name "*.toml" ")"  )
archive_contents := $(shell find . "(" -name "*.py" -or -name "*.pyx" -or -name "*.pxd" ")")
$(info Archive contents: $(archive_contents))
player_nums := $(shell seq 1 $(SLOTS))
play_vs_qs_targets := $(player_nums:%=play_vs_qs/%)
version_combos := 9/1 9/2 9/3 9/4 10/1 10/2 10/3 10/4 11/1 11/2 11/3 11/4 12/1 12/2 12/3 12/4 13/1 13/2 13/3 13/4
play_vs_version_targets := $(version_combos:%=play_vs_v%)

.PHONY: all play_vs_qs_targets

all: dist/archive.zip

dist/archive.zip: $(archive_contents)
	mkdir -p $(@D)
	zip -r "$@" $(archive_contents)

$(RELEASE_PATH): $(archive_contents)
	#cargo build --release

$(play_vs_qs_targets): play_vs_qs/%: $(RELEASE_PATH)
	export PORTS="$$(seq $(START_PORT) $$(($(START_PORT)+$*-1)))" \
		&& export TMP_FILE="$$(mktemp /tmp/aicup2022-config.json.XXXXXX)" \
		&& echo "Temp config: $${TMP_FILE}" 1>&2 \
		&& jq -n --argjson ports "$$(echo $${PORTS} | jq -s)" --argjson seed "$(SEED)" \
			'{"seed": $$seed, "game": {"Create": "$(ROUND)"},"players": (($$ports | map({"Tcp": {"host": null,"port": .,"run": {"run_command": ("$(RUN_COMMAND)" | split(" "))},"accept_timeout": null,"single_timeout": null,"token": null}})) + ([range(0;$(SLOTS)-($$ports | length))] | map("AutoBot")))}' \
			> "$${TMP_FILE}" \
		&& cat "$${TMP_FILE}" 1>&2 \
		&& { $(RUNNER_PATH) --config "$${TMP_FILE}" ;} \
		&& rm "$${TMP_FILE}"

$(play_vs_version_targets): play_vs_v%: $(RELEASE_PATH)
	export PORTS="$$(seq $(START_PORT) $$(($(START_PORT)+$(SLOTS)-1)))" \
		&& export TMP_FILE="$$(mktemp /tmp/aicup2022-config.json.XXXXXX)" \
		&& echo "Temp config: $${TMP_FILE}" 1>&2 \
		&& jq -n --argjson ports "$$(echo $${PORTS} | jq -s)" --argjson seed "$(SEED)" \
			'{"seed": $$seed, "game": {"Create": "$(ROUND)"},"players": (($$ports | map({"Tcp": {"host": null,"port": .,"accept_timeout": null,"timeout": null,"token": null}})) + ([range(0;$(SLOTS)-($$ports | length))] | map("QuickStart")))}' \
			> "$${TMP_FILE}" \
		&& cat "$${TMP_FILE}" 1>&2 \
		&& { $(RUNNER_PATH) --config "$${TMP_FILE}" \
			& { sleep 1 && echo "$${PORTS}" | head -n $(lastword $(subst /, ,$*)) | tail -n +$$(($(DEBUG)+1))  | xargs -P5 -n1 -t $(RELEASE_PATH) "$(HOST)" ;} \
			& { sleep 1 && echo "$${PORTS}" | tail -n +$$(($(lastword $(subst /, ,$*))+1))  | xargs -P5 -n1 -t $(VERSIONS_PATH)/$(VERSIONS_PREFIX)$(firstword $(subst /, ,$*)) "$(HOST)" ;} \
		;} \
		&& rm "$${TMP_FILE}"
