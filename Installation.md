# 1 一种极简的conda环境配置方法

> 告别臃肿的`conda`和`miniconda`

```powershell
Invoke-Expression ((Invoke-WebRequest -Uri https://micro.mamba.pm/install.ps1 -UseBasicParsing).Content)
```

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```

```bash
micromamba self-update
```

为节省C盘空间，路径记得放到`D:\micromamba`。

## 1.1 配置

```bash
pip install uv
uv install earthengine-api --system # 默认安装在base env
# uv tool install jupyterlab
# uv tool install radian
```


# 2 earthengine-api

```bash
earthengine set_project gee-hydro # 这里请改为你自己的Project
```

<https://developers.google.com/earth-engine/guides/auth?hl=zh-cn>
