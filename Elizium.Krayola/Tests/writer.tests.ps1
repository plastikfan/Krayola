
Describe 'writer' {
  BeforeAll {
    Get-Module Elizium.Krayola | Remove-Module
    Import-Module .\Output\Elizium.Krayola\Elizium.Krayola.psm1 `
      -ErrorAction 'stop' -DisableNameChecking

    [hashtable]$script:_theme = $(Get-KrayolaTheme);
  }

  BeforeEach {
    $script:_writer = New-Writer ($_theme);
  }

  Context 'given: ad-hoc' {
    It 'should: write in colour' {
      $_writer.red().Text('Are you master of your domain? '). `
        blue().TextLn('Yeah, Im still king of the county!');

      $_writer.red().bgMagenta().Text('Are you master of your domain? '). `
        blue().bgDarkCyan().TextLn('Yeah, Im still lord of the manner!');
    }

    It 'should: write in theme colours' {
      $_writer.ThemeColour('affirm').TextLn('This is affirmed text');
      $_writer.ThemeColour('key').TextLn('This is key text');
      $_writer.ThemeColour('message').TextLn('This is message text');
      $_writer.ThemeColour('meta').TextLn('This is meta text');
      $_writer.ThemeColour('value').TextLn('This is value text');
    }

    Context 'and: style' {
      It 'should: not affect text display' {
        $_writer.bold().TextLn('This is *bold* text');
        $_writer.italic().TextLn('This is /italic/ text');
        $_writer.strike().TextLn('This is s-t-r-i-k-e--t-h-r-u text');
        $_writer.under().TextLn('This is _underlined_ text');
      }
    }
  }

  Context 'given: pair' {
    Context 'and: pair is PSCustomObject' {
      It 'should: write pair' {
        $_writer.Pair(@{ Key = 'Greetings'; Value = 'Earthlings'; Affirm = $true; }).Cr();
        $_writer.PairLn(@{ Key = 'Greetings'; Value = 'Earthlings'; });
      }
    }

    Context 'and: pair is couplet' {
      It 'should: write pair' {
        $_writer.Pair($(KP('a-key', 'a-value'))).Cr();
        $_writer.PairLn($(KP('a-key', 'a-value', $true)));
      }
    }
  } # given: pair

  Context 'given: line' {
    Context 'and: without message' {
      It 'should: write line' {
        [array]$pairs = @(
          $(KP('name', 'art vanderlay')),
          $(KP('occupation', 'architect')),
          $(KP('quip', "i'm back baby, i'm back", $true))
        );

        $_writer.Line($(KL($pairs)));
      }
    }

    Context 'and: with message' {
      It 'should: write line' {
        [array]$pairs = @(
          $(KP('name', 'frank')),
          $(KP('festivity', "The airance of grievances", $true))
        );

        [string]$message = 'Festivus for the rest of us';
        $_writer.Line($message, $(KL($pairs)));
      }
    }
  }
}

Describe 'Writer code generator' {
  It 'should: generate colour methods' -Skip {
    # Use this test to make updates to colour methods, without having to code up
    # every method manually.
    #
    [array]$fgColours = @('black', 'darkBlue', 'darkGreen', 'darkCyan',
      'darkRed', 'darkMagenta', 'darkYellow', 'gray', 'darkGray', 'blue', 'green',
      'cyan', 'red', 'magenta', 'yellow', 'white');

    [array]$bgColours = @('bgBlack', 'bgDarkBlue', 'bgDarkGreen', 'bgDarkCyan',
      'bgDarkRed', 'bgDarkMagenta', 'bgDarkYellow', 'bgGray', 'bgDarkGray', 'bgBlue', 'bgGreen',
      'bgCyan', 'bgRed', 'bgMagenta', 'bgYellow', 'bgWhite');
      
    foreach ($col in $fgColours) {
      # Current state:
      #
      # [writer] black() {
      #   $this._fgc = 'black';
      #   return $this;
      # }
      # -----------------------------------------------

      $code = '[writer] {0}()';
      Write-Host "$($code -f $col)";
      Write-Host "{"

      $code = '   $this._fgc = ''{0}'';';
      Write-Host "$($code -f $col)";

      $code = '   return $this;';
      Write-Host "$code";
      Write-Host "}";

      Write-Host ""
    }

    foreach ($col in $bgColours) {
      $code = '[writer] {0}()';
      Write-Host "$($code -f $col)";
      Write-Host "{"

      $code = '   $this._bgc = ''{0}'';';
      Write-Host "$($code -f $col.Substring(2))";

      $code = '   return $this;';
      Write-Host "$code";
      Write-Host "}";

      Write-Host ""
    }
  }  
}
