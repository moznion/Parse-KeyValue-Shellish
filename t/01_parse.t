#!perl
use strict;
use warnings;
use utf8;
use Test::More;
use Parse::KeyValue::Shellish qw/parse_key_value/;

subtest 'basic string should be parsed rightly' => sub {
    my $str = "foo=bar buz=qux\thoge=fuga\npiyo=piyopiyo";
    is_deeply parse_key_value($str), {
        foo  => 'bar',
        buz  => 'qux',
        hoge => 'fuga',
        piyo => 'piyopiyo',
    };
};

subtest 'multi-byte string should be parsed rightly' => sub {
    my $str = 'ほげ=ふが ぴよ=ぴよぴよ';
    is_deeply parse_key_value($str), {
        'ほげ' => 'ふが',
        'ぴよ' => 'ぴよぴよ',
    };
};

subtest 'string that contains "=" should be parsed rightly' => sub {
    my $str = 'foo=bar=buz';
    is_deeply parse_key_value($str), {
        foo  => 'bar=buz',
    };
};

subtest 'string that contains whitespace should be parsed rightly' => sub {
    my $str = qq{foo='bar buz' qux="hoge  fuga" piyo="piyo=piyo\tpiyo"};
    is_deeply parse_key_value($str), {
        foo  => 'bar buz',
        qux  => 'hoge  fuga',
        piyo => "piyo=piyo\tpiyo",
    };
};

subtest 'string that is needed escaping should be parsed rightly' => sub {
    my $str = q{foo="\"" bar='\' buz=\\ hoge=\(\) fuga=piyo\\};
    is_deeply parse_key_value($str), {
        foo  => '"',
        bar  => '\\',
        buz  => '\\',
        hoge => '()',
        fuga => 'piyo\\'
    }
};

subtest 'string that contains parenthesis should be parsed rightly' => sub {
    my $str = qq{foo=(aaa "bbb"\t'cc c'\ndd d) buz=() qux='()'};
    is_deeply parse_key_value($str), {
        foo => ['aaa', 'bbb', 'cc c', 'dd', 'd'],
        buz => [],
        qux => '()',
    };
};

subtest 'fail on parsing when invalid string is given' => sub {
    subtest 'given faked-escaping string' => sub {
        my $str = q{foo='\''};
        eval { parse_key_value($str) };
        like $@, qr/Unbalanced quotation: foo='\\''/;
    };

    # subtest 'given naked back-slash' => sub {
    #     my $str = 'foo=\ ';
    #     eval { parse_key_value($str) };
    #     ok $@;
    # };
    #
    subtest 'given unbalanced quote' => sub {
        subtest 'single-quote' => sub {
            my $str = "foo='";
            eval { parse_key_value($str) };
            ok $@;
        };

        subtest 'double-quote' => sub {
            my $str = 'foo="';
            eval { parse_key_value($str) };
            ok $@;
        };
    };

    subtest 'given unbalanced parenthesis' => sub {
        subtest 'left parenthesis' => sub {
            my $str = '(';
            eval { parse_key_value($str) };
            ok $@;
        };

        subtest 'right parenthesis' => sub {
            my $str = ')';
            eval { parse_key_value($str) };
            ok $@;
        };
    };
};

done_testing;

