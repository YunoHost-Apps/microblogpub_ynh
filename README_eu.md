<!--
Ohart ongi: README hau automatikoki sortu da <https://github.com/YunoHost/apps/tree/master/tools/readme_generator>ri esker
EZ editatu eskuz.
-->

# microblog.pub YunoHost-erako

[![Integrazio maila](https://dash.yunohost.org/integration/microblogpub.svg)](https://dash.yunohost.org/appci/app/microblogpub) ![Funtzionamendu egoera](https://ci-apps.yunohost.org/ci/badges/microblogpub.status.svg) ![Mantentze egoera](https://ci-apps.yunohost.org/ci/badges/microblogpub.maintain.svg)

[![Instalatu microblog.pub YunoHost-ekin](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=microblogpub)

*[Irakurri README hau beste hizkuntzatan.](./ALL_README.md)*

> *Pakete honek microblog.pub YunoHost zerbitzari batean azkar eta zailtasunik gabe instalatzea ahalbidetzen dizu.*  
> *YunoHost ez baduzu, kontsultatu [gida](https://yunohost.org/install) nola instalatu ikasteko.*

## Aurreikuspena

A self-hosted, single-user, ActivityPub powered microblog.


**Paketatutako bertsioa:** 2.0.0-v2~ynh1

**Demoa:** <https://microblog.pub>

## Pantaila-argazkiak

![microblog.pub(r)en pantaila-argazkia](./doc/screenshots/microblogpub_demo.png)

## Ezespena / informazio garrantzitsua

* Requires a dedicated domain
* You should not re-use a domain that was hosting another Fediverse software unless you know what you're doing

## Dokumentazioa eta baliabideak

- Aplikazioaren webgune ofiziala: <https://docs.microblog.pub>
- Erabiltzaileen dokumentazio ofiziala: <https://docs.migroblog.pub>
- Jatorrizko aplikazioaren kode-gordailua: <https://git.sr.ht/~tsileo/microblog.pub>
- YunoHost Denda: <https://apps.yunohost.org/app/microblogpub>
- Eman errore baten berri: <https://github.com/YunoHost-Apps/microblogpub_ynh/issues>

## Garatzaileentzako informazioa

Bidali `pull request`a [`testing` abarrera](https://github.com/YunoHost-Apps/microblogpub_ynh/tree/testing).

`testing` abarra probatzeko, ondorengoa egin:

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/microblogpub_ynh/tree/testing --debug
edo
sudo yunohost app upgrade microblogpub -u https://github.com/YunoHost-Apps/microblogpub_ynh/tree/testing --debug
```

**Informazio gehiago aplikazioaren paketatzeari buruz:** <https://yunohost.org/packaging_apps>
