# yubikey-auth

Node.js と pnpm は [nix/fixed-node.nix](nix/fixed-node.nix) で固定しています。依存関係の追加やCLIの実行には、`nix develop` または direnv が読み込んだ開発環境を使用してください。

## プロジェクト固有のスキル

[agent-skills-nix](https://github.com/Kyure-A/agent-skills-nix) を使い、[Better Auth公式スキル](https://github.com/better-auth/skills) の6種類を `.agents/skills/` に配置する設定です。グローバルのスキルにはインストールしません。

- `better-auth-best-practices`
- `create-auth`
- `email-and-password-best-practices`
- `organization-best-practices`
- `two-factor-authentication-best-practices`
- `better-auth-security-best-practices`

取得元と選択内容は `flake.nix`、取得するリビジョンは `flake.lock` で管理します。生成先の `.agents/skills/` はGit管理から除外しています。スキルの追加は、組織管理や2段階認証をアプリに導入するものではありません。

初回設定の完了には、リポジトリのルートで新しいinputsをlockし、スキルをビルド・配置します。

```sh
nix flake lock
nix build .#agent-skills-bundle --no-link
nix run .#skills-install-local
```

生成された `flake.lock` の差分を確認してコミットします。以後、`nix develop` / direnvでもスキルを同期します。手動同期も上記の `skills-install-local` で行えます。コマンドはリポジトリのルートから実行してください。

更新時は、更新対象のinputだけを指定します。

```sh
nix flake update better-auth-skills
nix run .#skills-install-local
```

同期先に既存の未管理ファイルがある場合は、上書きせずにエラーになります。生成先を直接編集せず、スキルの選択や取得元を `flake.nix` で変更してください。

## Cloudflare CLI

このプロジェクトでは [Cloudflare CLI `cf`](https://developers.cloudflare.com/cf/) を採用します。Workerを追加する際の設定形式は `cloudflare.config.ts` とし、Cloudflare Vite pluginと組み合わせます。[公式発表](https://blog.cloudflare.com/ja-jp/cloudflare-cf-cli-launch/)

現在はReact/Viteのひな形で、`cf`・Cloudflare Vite plugin・Workerは未導入です。`cf` はNixで固定したpnpmを使ってプロジェクトの開発依存に追加し、バージョンを固定します。

```sh
nix develop -c pnpm add -D -E cf
nix develop -c pnpm exec cf --version
```

`package.json` と `pnpm-lock.yaml` を一緒に管理し、既存の依存関係ポリシーを維持します。グローバルインストールや `npx` は使用しません。Workerの設定を追加してから `cf dev` / `cf build` / `cf deploy` を使用します。

## React + TypeScript + Vite template

This template provides a minimal setup to get React working in Vite with HMR and some Oxlint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Oxc](https://oxc.rs)
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/)

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the Oxlint configuration

If you are developing a production application, we recommend enabling type-aware lint rules by installing `oxlint-tsgolint` and editing `.oxlintrc.json`:

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "plugins": ["react", "typescript", "oxc"],
  "options": {
    "typeAware": true
  },
  "rules": {
    "react/rules-of-hooks": "error",
    "react/only-export-components": ["warn", { "allowConstantExport": true }]
  }
}
```

See the [Oxlint rules documentation](https://oxc.rs/docs/guide/usage/linter/rules) for the full list of rules and categories.
