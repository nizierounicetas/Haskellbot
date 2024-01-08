# Description
Telegram echo-bot written on Haskell that:
- reverses the user's text message (format: ```I'm playing tricks on <user's firstname>: <reversed text message>```);
- send back stickers;
- otherwise send ``` Can't answer on this :( ```
  
# Compile and run
1. Get token from BotFather;
2. Define ```BOT_TOKEN``` env variable;
3. Compile and run with <b>stack</b>:
   ```
   stack build
   stack run
   ```
Alternatively, you can use attached <b>Dockerfile</b> to build your own image with this bot, run container and/or push it to your <b>DockerHub</b>.
* to configure your own token run container with <b>-e</b> flag: ```-e BOT_TOKEN <your token>```

