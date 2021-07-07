# TODO: Fix the Catalog rules

PRODUCT_NAME 		?= CPSB-MCM
PRODUCT_VERSION ?= 1.0.0
PRODUCT_DIR			?= ./product
PRODUCT_TMP_DIR	 = ./product_tmp

CATALOG_INCLUDE = modules *.tf
CATALOG_EXCLUDE = modules/*/testing modules/*/README.md modules/.gitignore modules/cp4mcm/helm

build: fmt
	$(RM) -r $(PRODUCT_TMP_DIR)
	mkdir -p $(PRODUCT_TMP_DIR)/$(PRODUCT_NAME)
	for i in $(CATALOG_INCLUDE); do cp -r $$i $(PRODUCT_TMP_DIR)/$(PRODUCT_NAME); done
	for e in $(CATALOG_EXCLUDE); do $(RM) -r $(PRODUCT_TMP_DIR)/$(PRODUCT_NAME)/$$e; done
	cp CATALOG.md $(PRODUCT_TMP_DIR)/$(PRODUCT_NAME)/README.md
	cd $(PRODUCT_TMP_DIR) && COPYFILE_DISABLE=1 tar czfv $(PRODUCT_NAME)-$(PRODUCT_VERSION).tgz $(PRODUCT_NAME)
	mkdir -p $(PRODUCT_DIR)
	mv $(PRODUCT_TMP_DIR)/*.tgz $(PRODUCT_DIR)
	$(RM) -r $(PRODUCT_TMP_DIR)

clean-product:
	$(RM) -r $(PRODUCT_DIR)
