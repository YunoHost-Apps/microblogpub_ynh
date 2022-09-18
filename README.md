# Microblog.pub

A self-hosted, single-user, ActivityPub powered microblog.

You can find the documentation at [docs.microblog.pub](https://docs.microblog.pub).

## Screenshot

![Screenshot of Microblog.pub](./doc/screenshots/microblogpub_demo.png)

## Disclaimer

* Requires a dedicated domain
* You should not re-use a domain that was hosting another Fediverse software unless you know what you're doing
* Or re-use the domain if you stop hosting a microblog.pub server

## Install

```
sudo yunohost app install https://git.sr.ht/~tsileo/microblog.pub_ynh
```

## Update

```
sudo yunohost app upgrade microblogpub -u https://git.sr.ht/~tsileo/microblog.pub_ynh
```

## Uninstall

If you wish to uninstall the app, it is recommended to request the deletion of your remote profile:

```
sudo /opt/yunohost/microblogpub/inv.sh self-destruct
```

See [deleting the instance in the documentation](https://docs.microblog.pub/user_guide.html#deleting-the-instance) for more details.
