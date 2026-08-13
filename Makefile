help:
	@echo "Usage: make [target]"
	@echo "Available targets:"
	@echo "  install - Install the package"
	@echo "  docs    - Generate documentation"
	@echo "  check   - Check the package for issues"

install:
	Rscript -e "devtools::install()"

docs:
	Rscript -e "devtools::document()"

check:
	Rscript -e "devtools::check()"

.PHONY: help install docs check