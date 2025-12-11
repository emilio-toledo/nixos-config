{
  description = "Development environment templates";

  outputs =
    { self }:
    {
      templates = {
        node = {
          path = ./node;
          description = "Playwright development environment with Node.js, pnpm, bun, and moon";
        };
        default = self.templates.node;
      };
    };
}
