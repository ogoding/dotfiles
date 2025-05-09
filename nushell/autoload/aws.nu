module aws {
  export def find-resource [id: string] {
    print $"Finding ($id) using profile: ($env.AWS_PROFILE)"
    aws cloudformation describe-stack-resources --physical-resource-id $id
  }

  # TODO: Setup a sso-login and/or mfa-login? Or just leave it to the client files?
  export def sso-logout [] {
    rm -rf ~/.aws/sso
  }
}

