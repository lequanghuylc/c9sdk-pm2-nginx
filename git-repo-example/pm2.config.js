module.exports = {
    apps: [
      {
        name: "the-project",
        script: "./node_modules/.bin/ts-node ./index.ts",
        env: {
          NODE_PATH: "./src",
          PORT: 3001,
        },
      },
    ],
  };
  