module aws {
  export def find-resource [id: string] {
    print $"Finding ($id) using profile: ($env.AWS_PROFILE)"
    aws cloudformation describe-stack-resources --physical-resource-id $id
  }

  export def sso-logout [] {
    rm -rf ~/.aws/sso
  }

  export alias aws-mfa = uvx aws-mfa
}

overlay use aws;
