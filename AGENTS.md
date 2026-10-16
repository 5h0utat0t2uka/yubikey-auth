# Project instructions

- Node.js and pnpm are pinned by `nix/fixed-node.nix`. Run package commands inside `nix develop` (or the direnv environment), or use `nix develop -c pnpm ...`. Do not use a globally installed Node.js, npm, npx, pnpm, or Corepack to bypass the pinned toolchain.
- Preserve the dependency policies in `pnpm-workspace.yaml`, including `minimumReleaseAge`, `trustPolicy`, and `allowBuilds`. Commit dependency changes together with the generated lockfile.
- Use Cloudflare CLI `cf`, not Wrangler, for this project. Use `cloudflare.config.ts` and the Cloudflare Vite plugin when adding the Worker. Install `cf` as a project dev dependency with pnpm and invoke it through `pnpm exec cf` in the Nix environment. Do not install it globally.
- Project-local Better Auth skills are managed by `github:Kyure-A/agent-skills-nix` and sourced from `github:better-auth/skills`. Run `nix run .#skills-install-local` from the repository root to populate `.agents/skills/`; entering the dev shell also synchronizes them. Do not edit generated skills directly.
- Read the relevant installed `SKILL.md` before changing Better Auth code. Check examples against the resolved Better Auth version and its official documentation. Skill examples using npm/npx must be adapted to the pinned pnpm toolchain.
- Installing the organization and two-factor skills does not add those features to the application scope. Follow the authentication requirements agreed with the user.
- Use TypeScript, React, Vite, and plain CSS. Do not use Tailwind. Prioritize accessibility, privacy, and security. Keep secrets out of `VITE_*` variables.

References: [agent-skills-nix](https://github.com/Kyure-A/agent-skills-nix), [Better Auth skills](https://github.com/better-auth/skills), [Cloudflare CLI](https://developers.cloudflare.com/cf/).
