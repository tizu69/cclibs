# Scheduler

_This library comes with LuaLS documentation._

Have you ever used Create schedules in ComputerCraft, and asked yourself why
they are the way they are? Same :3 - like, what is this???

```lua
schedule = {
  cyclic = true,
  entries = {
    {
      instruction = {
        id = "create:destination",
        data = { text = "Station 1" },
      },
      conditions = {
        {
          {
            id = "create:delay",
            data = {
              value = 5,
              time_unit = 1,
            },
          },
          {
            id = "create:powered",
            data = {},
          },
        },
        {
          {
            id = "create:time_of_day",
            data = {
              rotation = 0,
              hour = 14,
              minute = 0,
              -- ...
```

Well, what if it were like this?

```lua
schedule = Scheduler.new(true)
    :to("Station 1")
    :wait(5):powered()
    :OR():time(14, 0, "daily")
```

Now it is! Full autocomplete and documentation included.

## Mod support

-   Create
-   Create Steam 'n' Rails
-   Create Crafts & Additions
-   .. easily extensible!

## Download

Scheduler is available for download as a 3KB library.

### Using DEPLOY

Install Scheduler easily using DEPLOY:

```sh
deploy get tizu69/cclibs/scheduler
```

Then, once you're ready for production, switch to the minified build as usual:

```sh
deploy now   # minify all DEPLOY libraries
deploy undo  # switch all DEPLOY libraries back to development size
```

### Manually

The files `scheduler.lua` and `schedulermin.lua` contain development-ready
and minified (-70% file size) code respectively. You may download it through
the GitHub interface.

A test file is provided, which you may use to confirm if Scheduler works as
intended. This requires you to have both versions installed.
