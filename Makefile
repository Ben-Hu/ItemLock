.PHONY= retail retail_ptr classic classic_ptr

all: retail retail_ptr classic classic_ptr

sync:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force $(shell pwd) $(WOW_DIR)

retail:
	WOW_DIR="$(WOW_DIR_RETAIL)" make sync

retail_ptr:
	WOW_DIR="$(WOW_DIR_RETAIL_PTR)" make sync

classic:
	WOW_DIR="$(WOW_DIR_CLASSIC)" make sync

classic_ptr:
	WOW_DIR="$(WOW_DIR_CLASSIC_PTR)" make sync
