## Contributing

- [VS Code prerequisites](https://github.com/Microsoft/vscode/wiki/How-to-Contribute#prerequisites)

```shell
yarn
yarn watch # Visit http://localhost:8080 once completed.
```

If you run into issues about a different version of Node being used, try running
`npm rebuild` in the VS Code directory.

If changes are made to the patch and you've built previously you must manually
reset VS Code then run `yarn patch:apply`.
