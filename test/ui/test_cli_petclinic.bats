PETCLINIC_CONFIG_FILE=./test/ui/data/petclinic/tkltest_ui_config.toml
PETCLINIC_OUTPUT_DIR=./__tkltest-output-ui-petclinic
PETCLINIC_CRAWL_DIR=$PETCLINIC_OUTPUT_DIR/localhost/crawl0
PETCLINIC_TEST_FILE=$PETCLINIC_CRAWL_DIR/src/test/java/generated/GeneratedTests.java

# setup commands run before execution of tests in file
setup_file() {
    echo "# setup_file: building webapp image" >&3
    cd test/ui/data/petclinic && ./deploy_app.sh build && cd ../../../..
    echo "# setup_file: deleting output dirs" >&3
    echo "#   - deleting $PETCLINIC_OUTPUT_DIR" >&3
    rm -rf $PETCLINIC_OUTPUT_DIR
}

teardown_file() {
    echo "# teardown_file: stopping webapp" >&3
    cd test/ui/data/petclinic && ./deploy_app.sh stop && cd ../../../..
}

setup() {
    echo "# setup: deploying webapp" >&3
    cd test/ui/data/petclinic && ./deploy_app.sh start && cd ../../../..
}

@test "Test 01: CLI generate petclinic" {
    # generate test cases for petclinic app
    run tkltest-ui --verbose \
        --config-file $PETCLINIC_CONFIG_FILE \
        --test-directory $PETCLINIC_OUTPUT_DIR \
        generate
    [ $status -eq 0 ]

    # assert that the crawl directory is created
    [ -d ./$PETCLINIC_CRAWL_DIR ]

    # assert that pom.xml and test class are generated
    [ -f ./$PETCLINIC_CRAWL_DIR/pom.xml ]
    [ -f ./$PETCLINIC_TEST_FILE ]

    # assert over number of generated tests
    test_count=`grep @Test $PETCLINIC_TEST_FILE | wc -l`
    echo "# test_count=$test_count" >&3
    [ $test_count -gt 0 ]
}

@test "Test 02: CLI execute petclinic" {
    # execute test cases for petclinic app
    run tkltest-ui --verbose \
        --config-file $PETCLINIC_CONFIG_FILE \
        --test-directory $PETCLINIC_OUTPUT_DIR \
        execute
    [ $status -eq 0 ]
}
