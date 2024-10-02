# Doing

# TODO, maybe

- can we wrap it as a stand-alone cli app?
- save prompts and responses
- support executing scripts as part of file expansion
  - I say `@!my-script.py`, it's expanded like this:
    ```md
    ### Script `my-script.py`
    ```python
    # my-script.py

    ... the code of my-script.py ...
    ```
    output
    ```stdout
    ... the output of my-script.py ...
    ```
    [exit code: 1]
    ```
- checklists / recipes / templates
  - state is in files
- interview-style workflow
  - state is in files
  - generate interview-#1.md, answer inline, generate interview-#2.md, etc
- [ ] Typist - if current buffer is a file, start a new buffer with this file in the context
- [ ] something something refactoring
- [ ] something something mermaid

# Done

- [x] key map to TypistApprove
- [x] key map to trigger typist
- [x] TypistApprove - close the tab after saving, and show toast to user
- [x] TypistTryHarder - use a stronger LLM model
- [x] parse response should return absolute paths for files
  - [x] extract path resolution to own file
- [x] expand file refs: look for files in the same directory as the current file
