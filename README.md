# Automatic SAT
### For Mexicans Who Struggle With The Awkward SAT's System For Invoice Generation

## Documentation

- [Installation And Requirements](#instalation-and-requirements)
- [Credentials Setup](#credentials-setup)
- [Sendgrid Setup](#sendgrid-setup)
- [Invoice Generation](#invoice-generation)

## Installation And Requirements

- [Docker](https://docs.docker.com/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Sendgrid Valid API Token For Email Sendings (It's free for up to 100 emails per day)](https://sendgrid.com/)

### Clone The Repo

```console
foo@bar:~$ git clone git@github.com:lacf95/automatic-sat.git
```

```console
foo@bar:~$ cd automatic-sat
```

### Build The Project

```console
foo@bar:automatic-sat$ docker-compose build
foo@bar:automatic-sat$ docker-compose pull
```

## Credentials Setup

By default Automatic SAT has a directory called `user-credentials` to store all the credentials.

You'll need to add your credentials inside a directory called the same as your RFC.

```console
foo@bar:automatic-sat$ mkdir -p user-credentials/your_rfc
```

You need these credentials inside that directory:
- `.cer` Certificate File
- `.key` Private Key File
- `.pass` Password File (Plain Text File With The Password Inside)

## Sendgrid Setup

You only need to add your API Key and the email you want to use for sending the emails inside the `sendgrid.env` file

```
SENDGRID_API_KEY=your_api_key
SENDGRID_FROM_EMAIL=your_email
```

## Invoice Generation

You can use the `invoices/sample.yml` as template for your invoices

```console
foo@bar:automatic-sat$ cp invoices/sample.yml invoices/2019_july.yml
```

Then configure as needed.

Once configured your invoices file you can execute the invoice generate script

```console
foo@bar:automatic-sat$ docker-compose run client ruby generate_invoices.rb invoices/2019_july.yml
```

You can pass as many files as required

```console
foo@bar:automatic-sat$ docker-compose run client ruby generate_invoices.rb invoices/2019_july.yml invoices/2019_august.yml
```
