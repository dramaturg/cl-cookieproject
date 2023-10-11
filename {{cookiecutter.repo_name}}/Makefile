LISP ?= {{ cookiecutter.lisp }}

{%- if cookiecutter.testing_framework != 'none' %}
all: test
{%- endif %}

run:
	rlwrap $(LISP) --load run.lisp \
		--eval '(swank:create-server)' \
		--eval '(in-package :{{ cookiecutter.project_name}})'

build:
	$(LISP)	--non-interactive \
		--load {{ cookiecutter.project_name}}.asd \
		--eval '(ql:quickload :{{ cookiecutter.project_name}})' \
		--eval '(asdf:make :{{ cookiecutter.project_name}})'

{%- if cookiecutter.testing_framework != 'none' %}
test:
	$(LISP) --non-interactive \
		--load run-tests.lisp
{%- endif %}
