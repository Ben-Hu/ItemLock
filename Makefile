.PHONY= srd sr scd sc

sr:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force -n $(shell pwd) $(WOW_DIR_RETAIL)

srd:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force $(shell pwd) $(WOW_DIR_RETAIL)

sc:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force -n $(shell pwd) $(WOW_DIR_CLASSIC)

scd:
	$(shell ls) | rsync -avur --exclude=.git/ --exclude=.gitignore --exclude=.envrc --delete --force $(shell pwd) $(WOW_DIR_CLASSIC)
