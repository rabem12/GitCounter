sed -i '' '/dependencies:/i\
    entitlements:\
      path: GithubCounter/GithubCounter.entitlements\
      properties:\
        com.apple.security.application-groups:\
          - group.io.githubcounter\
' project.yml

sed -i '' '/com.apple.security.network.client: true/a\
        com.apple.security.application-groups:\
          - group.io.githubcounter\
' project.yml
