import pwd, subprocess

c.JupyterHub.authenticator_class = 'nativeauthenticator.NativeAuthenticator'

c.Authenticator.admin_users = {'admin'}
c.Authenticator.check_common_password = True
c.Authenticator.minimum_password_length = 6
c.Authenticator.ask_email_on_signup = True


def pre_spawn_hook(spawner):

    username = spawner.user.name

    try:

        pwd.getpwnam(username)

    except KeyError:

        subprocess.check_call(['useradd', '-ms', '/bin/bash', username])

c.Spawner.pre_spawn_hook = pre_spawn_hook

c.Spawner.default_url = '/lab'