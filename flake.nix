{
  description = "A flake for a Node.js development environment with pnpm and TypeScript support.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks.url = "github:cachix/git-hooks.nix";
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    better-auth-skills = {
      url = "github:better-auth/skills";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-utils, git-hooks, agent-skills, better-auth-skills, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      fixedNode = import ./nix/fixed-node.nix { inherit pkgs system; };
      preCommit = import ./nix/pre-commit.nix { inherit pkgs git-hooks system fixedNode; src = ./.; };
      agentLib = agent-skills.lib.agent-skills;
      skillSources.better-auth.path = better-auth-skills;
      skillSelection = agentLib.selectSkills {
        sources = skillSources;
        catalog = agentLib.discoverCatalog skillSources;
        allowlist = [ ];
        skills = {
          better-auth-best-practices = {
            from = "better-auth";
            path = "better-auth/best-practices";
          };
          create-auth = {
            from = "better-auth";
            path = "better-auth/create-auth";
          };
          email-and-password-best-practices = {
            from = "better-auth";
            path = "better-auth/emailAndPassword";
          };
          organization-best-practices = {
            from = "better-auth";
            path = "better-auth/organization";
          };
          two-factor-authentication-best-practices = {
            from = "better-auth";
            path = "better-auth/twoFactor";
          };
          better-auth-security-best-practices = {
            from = "better-auth";
            path = "security";
          };
        };
      };
      skillBundle = agentLib.mkBundle { inherit pkgs; selection = skillSelection; };
      skillTargets.agents = agentLib.defaultLocalTargets.agents // { enable = true; };
      skillInstaller = agentLib.mkLocalInstallProgram {
        inherit pkgs;
        bundle = skillBundle;
        targets = skillTargets;
      };
    in
    {
      formatter = pkgs.nixfmt;
      checks = {
        pre-commit = preCommit;
        skills = skillBundle;
      };
      packages.agent-skills-bundle = skillBundle;
      apps.skills-install-local = {
        type = "app";
        program = "${skillInstaller}/bin/skills-install-local";
      };
      # packages = {
      #   create-project = createProject;
      #   scaffold-app = scaffoldApp;
      # };
      # apps = {
      #   create-project = {
      #     type = "app";
      #     program = "${createProject}/bin/create-project";
      #   };
      #   scaffold-app = {
      #     type = "app";
      #     program = "${scaffoldApp}/bin/scaffold-app";
      #   };
      # };
      devShells.default = pkgs.mkShell {
        packages = [
          fixedNode.nodejs
          fixedNode.pnpm
          pkgs.age
          pkgs.betterleaks
          pkgs.prek
          pkgs.semgrep
          pkgs.sops
          pkgs.typescript-language-server
          pkgs.zizmor
        ] ++ preCommit.enabledPackages;
        shellHook = ''
          ${preCommit.shellHook}
          ${agentLib.mkShellHook {
            inherit pkgs;
            bundle = skillBundle;
            targets = skillTargets;
            quiet = true;
          }}
          echo "node: $(node -v)"
          echo "pnpm: $(pnpm -v)"
        '';
      };
    }
  );
}
