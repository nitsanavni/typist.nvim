# Doing

# TODO, maybe

- run as stand-alone cli app
  - nvim --headless
  - "current buffer" from stdin or a file
  - diff view is headful
- save prompts and responses
- checklists / recipes / templates
  - state is in files
- interview-style workflow
  - state is in files
  - generate interview-#1.md, answer inline, generate interview-#2.md, etc
- [ ] Typist - if current buffer is a file, start a new buffer with this file in the context
- [ ] something something refactoring
- [ ] something something mermaid

# Done

- [x] support executing scripts as part of file expansion
- [x] key map to TypistApprove
- [x] key map to trigger typist
- [x] TypistApprove - close the tab after saving, and show toast to user
- [x] TypistTryHarder - use a stronger LLM model
- [x] parse response should return absolute paths for files
  - [x] extract path resolution to own file
- [x] expand file refs: look for files in the same directory as the current file
