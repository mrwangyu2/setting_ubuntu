# setting_ubuntu

把一台全新的 Ubuntu 工作站配置成能用的一台机器：apt 镜像、常用软件、fish / tmux /
neovim、Docker、Syncthing、Glances、gdu。

- **支持版本**：Ubuntu **18.04 / 22.04 / 26.04**（其它版本加 `--force` 可尝试）
- **幂等**：任何命令都可以重复执行，只补齐缺的部分，不会重复追加、不会装第二遍
- **非交互**：不需要按 `r` 重试，没有菜单；要么成功，要么明确报错
- **单入口**：全部逻辑在一个 Python 3 程序里，纯标准库，最老的 18.04 也能直接跑

## 快速开始

```bash
./setup.py list                 # 看有哪些任务
./setup.py plan                 # 只预览会改什么，不动系统（dry-run）
./setup.py run                  # 按顺序执行全部任务
./setup.py run apt-sources,base-packages   # 只跑指定任务（逗号或空格分隔）
```

常用参数：

| 参数 | 说明 |
|------|------|
| `--dry-run` | 只显示将要执行的动作，不落盘 |
| `--yes` | 覆盖已有用户配置时不询问（无人值守用） |
| `--mirror aliyun` | apt 镜像：`aliyun`(默认) / `tuna` / `ustc` / `cn` / `official` |
| `--pypi-mirror aliyun` | pip 镜像，默认跟随 `--mirror` |
| `--timezone Asia/Shanghai` | 时区 |
| `--proxy http://host:port` | 所有网络命令走代理（默认读 `$https_proxy`/`$http_proxy`） |
| `--hosts-entry "IP HOST"` | 可重复；把静态主机名写进 `/etc/hosts`（`hosts` 任务） |
| `--upgrade` | 刷新 gdu 这类独立二进制 |
| `--force` | 在非 18.04/22.04/26.04 上继续 |
| `--user` / `--home` | 指定目标用户与家目录 |
| `--no-color` / `--verbose` | 关闭颜色 / 打印失败堆栈 |

## 任务

按注册顺序执行，每个任务都自成一体，也可以单独跑：

| 任务 | 作用 |
|------|------|
| `apt-sources` | 配置 apt 镜像；≥24.04 写 deb822 `ubuntu.sources`，≤22.04 写经典 `sources.list` |
| `pip-sources` | 写 `~/.config/pip/pip.conf` |
| `hosts` | 用受管块维护 `/etc/hosts`（需 `--hosts-entry`，否则跳过） |
| `timezone` | 设置时区 |
| `base-packages` | 读 `resources/lists/base.txt` 批量安装 |
| `nodejs` | NodeSource 源安装 Node（18.04→16，其余→22） |
| `docker` | 官方源装 Docker Engine；该发行版还没构建时自动回退 `docker.io`，装好后不再重试 |
| `syncthing` | 官方源安装并 `systemctl enable --now syncthing@<user>` |
| `glances` | 在 `/opt/glances` 建 venv，装成 server + gotty web 终端两个 systemd 服务 |
| `gdu` | 安装磁盘占用分析工具 `gdu` |
| `fish` | fish + fisher 插件管理器 + fish-ai (对接 deepseek/new-api) + 受管配置 |
| `tmux` | tmux + tpm + 插件 + 受管 `~/.tmux.conf` |
| `nvim` | neovim + 配置 + vim-plug + Python provider |

## 目录结构

```
setup.py                 入口（可直接执行）
su/
  cli.py                 参数解析 / 任务编排 / 汇总
  system.py             从 /etc/os-release 识别发行版、codename、架构、用户
  runner.py             命令执行：sudo / dry-run / apt 缓存 / 日志的唯一出口
  fileutil.py           幂等原语：write / ensure_block / ensure_copy / ensure_binary / sync_dir ...
  systemd.py            安装并启用 systemd 单元
  apt.py                dpkg 查询、批量安装、加 key、写 repo、ensure_signed_repo
  pip.py                pip 安装（≥24.04 自动加 --break-system-packages）
  options.py            任务可见的选项（不把 argparse Namespace 传得到处都是）
  mirrors.py            apt / pypi 镜像表
  tasks/                每个任务一个文件，注册表在 tasks/__init__.py
resources/
  lists/*.txt           纯数据：apt / pip 包名清单
  nvim_script/          neovim 配置（原样保留）
  tmux_script/          tmux 配置
  glances_script/       glances.conf 与 gotty 二进制
  fish_script/          fish 配置与 fish-ai 配置模板
tests/test_setting_ubuntu.py   纯离线单元测试
```

## 幂等的实现方式

| 场景 | 原来 | 现在 |
|------|------|------|
| 写文件 | `cp` 无条件覆盖 | 内容不同才写，并留一份 `.setting_ubuntu.bak` |
| 追加配置 | `>>` 每次都追加 | `ensure_block` 用标记块原地替换，不重复 |
| 装包 | 每次 `apt install` | 先 `dpkg-query`，只装缺的 |
| 克隆仓库 | `git clone` 重复报错 | 已存在则 `[SKIP]` |
| 签名 key | 存在就永不更新 | 每次重新拉取比对，变了才替换；网络失败时保留旧 key |
| systemd | 每次 start/enable | 内容没变就不 reload，没跑才 restart |
| Docker 回退 | 每次重新尝试 CE 源 | 已装 `docker-ce`/`docker.io` 就直接跳过 |

## 相对旧版本的行为变化

- **`/etc/hosts` 改为可选、受管块**：原来写死的 `199.232.4.133 raw.githubusercontent.com`
  已失效，且每次运行都会追加一行。现在只有传 `--hosts-entry` 才写，且用标记块原地替换。
- **Glances 保持原有 gotty 行为**：仍是 `glances -s`（61209）+ gotty 终端（8960）两个服务，
  只把写死的 `/home/frank`、`python3.10` 换成 `/opt/glances` venv 与自动生成的 systemd 单元。
- **neovim 不再用 `LspInstall`**：新版 lspconfig 已移除该命令，clangd / ripgrep 改为 apt 安装；
  neovim < 0.9 时自动加 `ppa:neovim-ppa/stable`。
- **去掉 `libncurses5-dev` / `liblua5.1-dev` / `python3-neovim`**：在 26.04 上已不存在，
  分别用 `libncurses-dev` 和 pip 的 `pynvim` 替代。
- **删除 Vundle 克隆**：neovim 用 vim-plug。
- **移除 zsh 任务**：不再安装 zsh / oh-my-zsh / fzf 与 `.zshrc`，交互式 shell 统一由
  `fish` 任务负责（含 Fisher 与 fish-ai）。
- **不再单独装 `npm`**：NodeSource 的 `nodejs` 已自带 npm。
- **不再硬编码用户 `frank`**：用户名来自 `SUDO_USER` / 当前用户，home 来自 `pwd`；
  以 root 直接运行且未指定 `--user` 时会告警。

## 网络 / 代理

如果本机 DNS 不可用（例如被 WireGuard 抢了默认 DNS），`git clone`、`curl`、`pip` 会
`Could not resolve host`。让 `setup.py` 统一走代理即可：

```bash
./setup.py run --proxy http://192.168.3.10:7897
# 或先导出，脚本会自动继承：
export https_proxy=http://192.168.3.10:7897 http_proxy=http://192.168.3.10:7897
./setup.py run
```

- `git` / `curl` / `pip` / `npm` 通过 `http_proxy`/`https_proxy`/`all_proxy` 环境变量走代理。
- `apt` 不读环境变量（且 `sudo` 会清空环境），所以脚本改用
  `-o Acquire::http::Proxy=... -o Acquire::https::Proxy=...` 传给每条 `apt-get`。
- `sudo` 下的 `pip` 同理不受环境变量影响，脚本改用 `pip --proxy <url>`。
- 网络命令（`git clone`、`curl` 下载、`pip` 安装、fisher 插件安装）会自动重试 3 次
  （间隔 2 秒），以应对本机代理偶发的 `TLS connect error: unexpected eof`。
- 已知例外：`nvim` 任务在 18.04/22.04 上会调用 `add-apt-repository` 加 PPA，该命令既不吃
  环境变量也不吃 `-o`；若那一步因网络失败，可先手动配好 apt 代理再重跑。

## 测试与手动验证

```bash
python3 -m unittest discover -s tests -v   # 离线单元测试（源码渲染、幂等原语、参数解析）
./setup.py plan --no-color                 # 全量预览，不改系统
./setup.py run pip-sources --home /tmp/su_test   # 用临时 HOME 验证幂等（跑两次第二次全 SKIP）
```
