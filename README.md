# Obelisk

### RDBMS for the Urbit computer

* Time traveling databases, every database state is indexed by time.

* Queries are (implicitly) idempotent, thanks to indexed database states.

* Tables, views, and query results are always proper sets of the data rows.

* No NULLS, anywhere, ever.

* Scripts are atomic (pass/fail)

Obelisk employs a dialect of SQL called "urQL" that provides for these properties.

See [Reference/Preliminaries](/docs/reference/01-preliminaries.md) and the [Users Guide](/docs/users-guide.md) in the docs folder for more information.

### Sample database

This repository includes a sample database, "animal-shelter", derived from https://github.com/ami-levin/Animal_Shelter.  

### Bug reporting

Reporting bugs is encouraged and appreciated. Please open an issue with a minimal urQL script reproducing the bug using the sample database, or if it's not possible to reproduce in the sample database provide the full DDL and urQL script to reproduce.

Reporting documentation bugs is also appreciated.

### Contributions

This project welcomes contributors. Contact the author for more information.

### Using the %hawk UI

To interact with Obelisk from %hawk:

- Ensure you have %hawk installed
  `|install ~dister-migrev-dolseg %hawk`
- Create a file in your hawk namespace
- Get the latest Obelisk UI template from https://hawk.computer/~~/templates/. Paste the contents into into the hawk file. (templates/hawk.txt in this repo is not necessarily current)

### Alpha release

The current **v0.5-alpha** release requires manual installation.

See the [releases document](/releases.md) for new functionality.

#### Previous alpha is NOT installed

```
|new-desk %obelisk
|mount %obelisk
```

Clone the Obelisk repo to your machine.
On the `master` branch find the folder with the desk files and copy to the obelisk desk that you mounted.

```
 cp -rL ~/gitrepos/obelisk/desk/* /path/to/your/pier-ship/obelisk
 ```

```
|commit %obelisk
|install our %obelisk
```

#### Previous alpha is installed

The current release is NOT compatible with the previous release.

If you wish to save data, you will have to back it up and recreate it before nuking the agent. (See below.)

Copy the files to your desk, nuke the agent, and commit the files.

```
|nuke %obelisk
|commit %obelisk
```

Don't worry about the sample animal-shelter database. You can recreate it as before in the new release.

List the databases you have created. Ignore the 'sys' database.

```
FROM sys.sys.databases SELECT *;
```

In each database query the metadata views to retrieve your table definitions.

```
FROM sys.tables SELECT *;
FROM sys.columns SELECT *;
```

For each table you want to restore query the data and save the results. You will have to `CREATE` new databases and tables and `INSERT` the saved data.

```
FROM my-table SELECT *;
```

### Beta release

The upcoming beta release will likely not be compatible with the current alpha release, but it is planned to be on standard Urbit OTA software distribution, with future release compatibility handled by the OTA.

See [the roadmap](/docs/roadmap.md) for upcoming functionality.