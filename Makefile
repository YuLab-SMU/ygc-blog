publish:
	npx quartz build -d ../YuNotebooks -o docs ;\
	python cleanup_public_no_html.py ;\
	python correct-image-path.py ;\
	git add .;\
	git commit -m "update docs";\
	git push
