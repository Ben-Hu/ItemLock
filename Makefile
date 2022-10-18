.PHONY= retail retail_ptr classic classic_ptr

retail:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force $(shell pwd) $(WOW_DIR_RETAIL)

retail_ptr:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force $(shell pwd) $(WOW_DIR_RETAIL_PTR)

classic:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force $(shell pwd) $(WOW_DIR_CLASSIC)

classic_ptr:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force $(shell pwd) $(WOW_DIR_CLASSIC_PTR)
