package App::ModuleFeaturesUtils;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use Perinci::Sub::Args::Common::CLI qw(%argspec_detail);

our %SPEC;

our %argspecreq0_feature_set = (
    feature_set => {
        schema => 'perl::modulefeature::modname*',
        req => 1,
        pos => 0,
    },
);

our %argspecreq0_module = (
    module => {
        schema => 'perl::modname*',
        req => 1,
        pos => 0,
    },
);

$SPEC{':package'} = {
    v => 1.1,
    summary => 'CLI Utilities related to Module::Features',
};

$SPEC{list_feature_sets} = {
    v => 1.1,
    summary => 'List feature sets (in modules under Module::Features:: namespace)',
    args => {
        %argspec_detail,
    },
};
sub list_feature_sets {
    require Module::List::Tiny;

    my %args = @_;

    my $res = Module::List::Tiny::list_modules(
        "Module::Features::", {list_modules=>1, recurse=>1});

    my @rows;
    for my $mod (sort keys %$res) {
        (my $fsetname = $mod) =~ s/^Module::Features:://;
        if ($args{detail}) {
            (my $modpm = "$mod.pm") =~ s!::!/!g;
            require $modpm;

            my $spec = \%{"$mod\::FEATURES_DEF"};

            push @rows, {
                name => $fsetname,
                module => $mod,
                summary => $spec->{summary},
                num_features => (scalar keys %{$spec->{features}}),
            };
        } else {
            push @rows, $fsetname;
        }
    }
    [200, "OK", \@rows];
}

$SPEC{list_feature_set_features} = {
    v => 1.1,
    summary => 'List features in a feature set',
    args => {
        %argspecreq0_feature_set,
        %argspec_detail,
    },
};
sub list_feature_set_features {
    my %args = @_;

    my $mod = "Module::Features::$args{feature_set}";
    (my $modpm = "$mod.pm") =~ s!::!/!g;
    require $modpm;

    my $spec = \%{"$mod\::FEATURES_DEF"};

    my @rows;
    for my $fname (sort keys %{ $spec->{features} }) {
        my $fspec = $spec->{features}{$fname};
        if ($args{detail}) {
            push @rows, {
                name    => $fname,
                summary => $fspec->{summary},
                req     => $fspec->{req} // 0,
                schema  => $fspec->{schema} // 'bool',
            };
        } else {
            push @rows, $fname;
        }
    }
    [200, "OK", \@rows];
}

$SPEC{check_feature_set_spec} = {
    v => 1.1,
    summary => 'Check specification in %FEATURES_DEF in Modules::Features::* module',
    args => {
        %argspecreq0_feature_set,
        %argspec_detail,
    },
};
sub check_feature_set_spec {
    require Module::FeaturesUtil::Check;
    my %args = @_;

    my $mod = "Module::Features::$args{feature_set}";
    (my $modpm = "$mod.pm") =~ s!::!/!g;
    require $modpm;

    my $spec = \%{"$mod\::FEATURES_DEF"};
    Module::FeaturesUtil::Check::check_feature_set_spec($spec);
}

$SPEC{check_feature_decl} = {
    v => 1.1,
    summary => 'Check specification in %FEATURES in a module',
    args => {
        %argspecreq0_module,
        %argspec_detail,
    },
};
sub check_features_decl {
    require Module::FeaturesUtil::Check;
    my %args = @_;

    my $mod = "Module::Features::$args{module}";
    (my $modpm = "$mod.pm") =~ s!::!/!g;
    require $modpm;

    my $features = \%{"$mod\::FEATURES"};
    Module::FeaturesUtil::Check::check_features_decl($features);
}

1;
#ABSTRACT:

=head1 DESCRIPTION

This distribution includes the following utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<Module::Features>
