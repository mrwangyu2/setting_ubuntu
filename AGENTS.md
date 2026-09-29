# setting_ubuntu — agent 记忆

## 网络

### 结论
- **HTTP/HTTPS 代理：`192.168.3.10:7897`**（已在 TCP 层验证可用，`http://` 与 `https://` 均返回 200）。
  需要在 shell 里显式导出，例如：

```bash
export http_proxy=http://192.168.3.10:7897
export https_proxy=http://192.168.3.10:7897
```

- 安装类命令（`npx`、`git clone`、`curl`、`pip`、`npm`）在本机**必须走该代理**。
- GitHub API/raw 通过代理偶发 `TLS connect error ... unexpected eof while reading`，
  属瞬时空闲连接问题，**重试 1-3 次即可成功**，脚本里应对网络请求做重试。

### DNS 故障根因（已诊断，2026-09 现状）
- **不是** `systemd-resolved` 挂了，也**不是** 53 端口没监听。实测：
  - `systemd-resolved` 状态 `enabled` + `active`，正常监听 `127.0.0.53:53` 与 `127.0.0.54:53`
  - `/etc/resolv.conf` → `../run/systemd/resolve/stub-resolv.conf`（stub 模式，正常）
  - 上游 DNS 配的是 `223.5.5.5`、`114.114.114.114`（在 `enp2s0f1` 上，来自 netplan），**本身可达**
- **真正根因**：`wg0` 接口（WireGuard，IP `10.50.0.6/24`）被 systemd-resolved 标记为
  `+DefaultRoute` 且 `DNS Domain: ~.`（即"所有域名都走我"），DNS 服务器 `223.5.5.5` 挂在 wg0 上；
  但 wg0 隧道实际不通（且**没有**默认路由，默认路由走 `enp2s0f1` → `192.168.3.1`）。
  resolved 优先把查询发给 wg0 的 DNS → 全部超时。
- 验证方式：
  - `dig @223.5.5.5 github.com +short` → **成功**（经 enp2s0f1 出口）
  - `dig @127.0.0.53 github.com` → **超时**
  - `resolvectl query github.com` → `All attempts to contact name servers or networks failed`
  - `resolvectl status` 可看到 `Link 5 (wg0)` 带 `+DefaultRoute` 和 `DNS Domain: ~.`

### 处理约定
- **不要动 `wg0`**（用户明确要求）。不要跑 `wg-quick down wg0`、不要改 `/etc/wireguard/wg0.conf`、
  不要用 `resolvectl` 清 wg0 的 dns/domain。
- 因此本机上网**一律走代理**（见上），不要依赖本机 DNS 直连。
- 如未来要修，可行方向（需用户确认）：注释掉 wg 配置里的 `DNS =` 行，或
  `sudo resolvectl dns wg0 "" && sudo resolvectl domain wg0 "" && sudo resolvectl default-route wg0 no`。
  注意：运行时改动重启/重连后失效。
- **`sudo` 需要交互密码**，agent 环境无 TTY，无法执行任何 `sudo` 命令（`sudo -n true` 失败，
  无 ssh-askpass）。需要 root 的操作必须让用户手动跑，或先配置 NOPASSWD。

### 本机信息
- 主机名 `ubuntu-m75n`，用户 `frank`（uid 1000，在 `sudo` 组）。
- 有线网卡 `enp2s0f1` = `192.168.3.11/24`，gateway `192.168.3.1`；无线 `wlp1s0` 未使用。
- `node`/`npx`/`pi` 在 `/home/frank/.local/node22/bin`（v22.23.2），可能不在默认 PATH 里，
  用前先 `export PATH=$PATH:/home/frank/.local/node22/bin`。

## Pi coding agent skills
- 全局 skills 目录：`~/.pi/agent/skills/`
- 已安装 **Matt Pocock skills** 于 `~/.pi/agent/skills/mattpocock-skills/`（`git clone` 自
  https://github.com/mattpocock/skills，MIT，38 个 skills，含 `skills/engineering/`、
  `skills/productivity/`、`skills/in-progress/`、`skills/misc/` 分组）。
- Pi 递归发现 `skills/**/SKILL.md`；其中 `disable-model-invocation: true` 的 skills
  不出现在系统提示里，只能通过 `/skill:<name>` 手动调用（如 `grill-me`、`ask-matt`、`triage`、
  `handoff`、`implement`、`to-spec`、`to-tickets`、`wayfinder`、`grill-with-docs` 等）。
- 首次使用前在每个仓库跑一次 `/skill:setup-matt-pocock-skills`，配置 issue tracker、
  triage labels 与文档存放位置；它会产生 `CONTEXT.md` 与 `.agents/` 相关文件。
- 更新：`cd ~/.pi/agent/skills/mattpocock-skills && git pull`（**需带代理环境变量**）。
- 官方另一种安装方式是 `npx skills@latest add mattpocock/skills`，但本机 DNS 损坏，
  推荐直接用上面的 `git clone`/`git pull` 方式。

## Pi coding agent 扩展

### Firecrawl（网页抓取 / 搜索）
- pi **没有内置 MCP**（`docs/usage.md:310`），所以用原生扩展实现：
  `~/.pi/agent/extensions/firecrawl.ts`（注册 5 个工具 + 1 个命令）
- 工具：`firecrawl_scrape`、`firecrawl_search`、`firecrawl_map`、`firecrawl_crawl`、
  `firecrawl_credits`；命令 `/firecrawl` 显示 key 来源与剩余额度
- **API key**：`~/.pi/agent/firecrawl.json`（权限 `0600`，内容 `{"apiKey":"fc-..."}`），
  可用环境变量 `FIRECRAWL_API_KEY` 覆盖
- **网络**：扩展用全局 `fetch`，走 pi 的 undici 代理 dispatcher；已在
  `~/.pi/agent/settings.json` 加 `"httpProxy": "http://192.168.3.10:7897"`，
  所以 pi 不必依赖 shell 里的 `export`
- 代理偶发 TLS 瞬断，扩展的 `call()` 已内置 3 次重试
- 改动扩展后在 pi 里 `/reload`（或重启）生效；用 `pi -e ~/.pi/agent/extensions/firecrawl.ts` 可临时测试
