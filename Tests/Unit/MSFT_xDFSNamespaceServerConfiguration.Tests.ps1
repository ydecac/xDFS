$script:DSCModuleName   = 'xDFS'
$script:DSCResourceName = 'MSFT_xDFSnamespaceServerConfiguration'

#region HEADER
# Unit Test Template Version: 1.1.0
[System.String] $script:moduleRoot = Join-Path -Path $(Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))) -ChildPath 'Modules\xDFS'
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -TestType Unit
#endregion HEADER

# Begin Testing
try
{
    # Ensure that the tests can be performed on this computer
    $productType = (Get-CimInstance Win32_OperatingSystem).ProductType
    Describe 'Environment' {
        Context 'Operating System' {
            It 'should be a Server OS' {
                $productType | Should Be 3
            }
        }
    }

    if ($productType -ne 3)
    {
        break
    }

    $featureInstalled = (Get-WindowsFeature -Name FS-DFS-Namespace).Installed
    Describe 'Environment' {
        Context 'Windows Features' {
            It 'should have the DFS Namespace Feature Installed' {
                $featureInstalled | Should Be $true
            }
        }
    }

    if ($featureInstalled -eq $false)
    {
        break
    }

    #region Pester Tests
    InModuleScope $script:DSCResourceName {
        # Create the Mock Objects that will be used for running tests
        $namespaceServerConfiguration = [PSObject]@{
            LdapTimeoutSec               = 45
            SyncIntervalSec              = 5000
            UseFQDN                      = $True
        }

        $namespaceServerConfigurationSplat = [PSObject]@{
            IsSingleInstance             = 'Yes'
            LdapTimeoutSec               = $namespaceServerConfiguration.LdapTimeoutSec
            SyncIntervalSec              = $namespaceServerConfiguration.SyncIntervalSec
            UseFQDN                      = $namespaceServerConfiguration.UseFQDN
        }

        Describe "MSFT_xDFSnamespaceServerConfiguration\Get-TargetResource" {
            Context 'Namespace Server Configuration Exists' {
                Mock Get-DFSNServerConfiguration -MockWith { $namespaceServerConfiguration }

                It 'should return correct namespace server configuration values' {
                    $result = Get-TargetResource -IsSingleInstance 'Yes'
                    $result.LdapTimeoutSec            | Should Be $namespaceServerConfiguration.LdapTimeoutSec
                    $result.SyncIntervalSec           | Should Be $namespaceServerConfiguration.SyncIntervalSec
                    $result.UseFQDN                   | Should Be $namespaceServerConfiguration.UseFQDN
                }

                It 'should call the expected mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                }
            }
        }

        Describe "MSFT_xDFSnamespaceServerConfiguration\Set-TargetResource" {
            Mock Get-DFSNServerConfiguration -MockWith { $namespaceServerConfiguration }
            Mock Set-DFSNServerConfiguration

            Context 'Namespace Server Configuration all parameters are the same' {
                It 'should not throw error' {
                    {
                        $splat = $namespaceServerConfigurationSplat.Clone()
                        Set-TargetResource @splat
                    } | Should Not Throw
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                    Assert-MockCalled -commandName Set-DFSNServerConfiguration -Exactly 0
                }
            }

            Context 'Namespace Server Configuration LdapTimeoutSec is different' {
                It 'should not throw error' {
                    {
                        $splat = $namespaceServerConfigurationSplat.Clone()
                        $splat.LdapTimeoutSec = $splat.LdapTimeoutSec + 1
                        Set-TargetResource @splat
                    } | Should Not Throw
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                    Assert-MockCalled -commandName Set-DFSNServerConfiguration -Exactly 1
                }
            }

            Context 'Namespace Server Configuration SyncIntervalSec is different' {
                It 'should not throw error' {
                    {
                        $splat = $namespaceServerConfigurationSplat.Clone()
                        $splat.SyncIntervalSec = $splat.SyncIntervalSec + 1
                        Set-TargetResource @splat
                    } | Should Not Throw
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                    Assert-MockCalled -commandName Set-DFSNServerConfiguration -Exactly 1
                }
            }

            Context 'Namespace Server Configuration UseFQDN is different' {
                It 'should not throw error' {
                    {
                        $splat = $namespaceServerConfigurationSplat.Clone()
                        $splat.UseFQDN = -not $splat.UseFQDN
                        Set-TargetResource @splat
                    } | Should Not Throw
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                    Assert-MockCalled -commandName Set-DFSNServerConfiguration -Exactly 1
                }
            }
        }

        Describe "MSFT_xDFSnamespaceServerConfiguration\Test-TargetResource" {
            Mock Get-DFSNServerConfiguration -MockWith { $namespaceServerConfiguration }

            Context 'Namespace Server Configuration all parameters are the same' {
                It 'should return true' {
                    $splat = $namespaceServerConfigurationSplat.Clone()
                    Test-TargetResource @splat | Should Be $True
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                }
            }

            Context 'Namespace Server Configuration LdapTimeoutSec is different' {
                It 'should return false' {
                    $splat = $namespaceServerConfigurationSplat.Clone()
                    $splat.LdapTimeoutSec = $splat.LdapTimeoutSec + 1
                    Test-TargetResource @splat | Should Be $False
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                }
            }

            Context 'Namespace Server Configuration SyncIntervalSec is different' {
                It 'should return false' {
                    $splat = $namespaceServerConfigurationSplat.Clone()
                    $splat.SyncIntervalSec = $splat.SyncIntervalSec + 1
                    Test-TargetResource @splat | Should Be $False
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                }
            }

            Context 'Namespace Server Configuration UseFQDN is different' {
                It 'should return false' {
                    $splat = $namespaceServerConfigurationSplat.Clone()
                    $splat.UseFQDN = -not $splat.UseFQDN
                    Test-TargetResource @splat | Should Be $False
                }

                It 'should call expected Mocks' {
                    Assert-MockCalled -commandName Get-DFSNServerConfiguration -Exactly 1
                }
            }
        }
    }
    #endregion
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
