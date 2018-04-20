# Instructions for Storing DOCX files in Git

## Config

### Global

Append to `~/.gitconfig`

```sh
[diff "pandoc"]
  textconv=pandoc --to=markdown
  prompt = false
[alias]
  wdiff = diff --word-diff=color --unified=1
```

Install pandoc if not already present (e.g. brew install pandoc)

### Repo

Append to `./.gitattributes`

```sh
*.docx diff=pandoc
```

## Usage

```sh
git wdiff some_file.docx

git show some_file.docx

git add some_file.docx && git commit
```

## Reference

[Blog post](http://blog.martinfenner.org/2014/08/25/using-microsoft-word-with-git/)
