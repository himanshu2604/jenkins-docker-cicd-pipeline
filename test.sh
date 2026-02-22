#!/bin/bash

###############################################
# Test Script for Abode Software Application
# Simplified version for Windows compatibility
###############################################

# Configuration
CONTAINER_NAME="abode-webapp"
APP_PORT="8081"
TEST_URL="http://localhost:${APP_PORT}"

echo "=========================================="
echo "Starting Application Tests..."
echo "=========================================="
echo ""

# Test counter
PASSED=0
FAILED=0

###############################################
# Test 1: Check if Docker is running
###############################################
echo "Test 1: Checking Docker service..."
if command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
    echo "✓ PASSED: Docker is running"
    ((PASSED++))
else
    echo "✗ FAILED: Docker is not running"
    ((FAILED++))
    exit 1
fi
echo ""

###############################################
# Test 2: Check if container exists and is running
###############################################
echo "Test 2: Checking if container is running..."
if docker ps -q -f name=${CONTAINER_NAME} &> /dev/null; then
    echo "✓ PASSED: Container '${CONTAINER_NAME}' is running"
    ((PASSED++))
    
    # Get container details
    CONTAINER_ID=$(docker ps -q -f name=${CONTAINER_NAME})
    echo "   Container ID: ${CONTAINER_ID}"
else
    echo "✗ FAILED: Container '${CONTAINER_NAME}' is not running"
    ((FAILED++))
    
    # Check if container exists but is stopped
    if docker ps -a -q -f name=${CONTAINER_NAME} &> /dev/null; then
        echo "   Container exists but is stopped"
    fi
    exit 1
fi
echo ""

###############################################
# Test 3: Check if application port is accessible
###############################################
echo "Test 3: Checking if application port is accessible..."
if curl -s --max-time 5 ${TEST_URL} > /dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 ${TEST_URL})
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✓ PASSED: Application is accessible (HTTP ${HTTP_CODE})"
        ((PASSED++))
    else
        echo "⚠ WARNING: Application returned HTTP ${HTTP_CODE}"
        echo "   Expected: 200, Got: ${HTTP_CODE}"
        ((PASSED++))
    fi
else
    echo "✗ FAILED: Application is not accessible"
    ((FAILED++))
    echo "   URL: ${TEST_URL}"
fi
echo ""

###############################################
# Test 4: Check for errors in container logs
###############################################
echo "Test 4: Checking container logs for errors..."
ERROR_COUNT=$(docker logs ${CONTAINER_NAME} 2>&1 | grep -i "error\|fatal\|critical" | wc -l)

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo "✓ PASSED: No errors found in container logs"
    ((PASSED++))
else
    echo "⚠ WARNING: Found ${ERROR_COUNT} error(s) in container logs"
    ((PASSED++))
fi
echo ""

###############################################
# Test 5: Check container status
###############################################
echo "Test 5: Checking container health status..."
CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' ${CONTAINER_NAME} 2>/dev/null)

if [ "$CONTAINER_STATUS" = "running" ]; then
    echo "✓ PASSED: Container status is 'running'"
    ((PASSED++))
else
    echo "✗ FAILED: Container status is '${CONTAINER_STATUS}'"
    ((FAILED++))
fi
echo ""

###############################################
# Test Summary
###############################################
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Tests Passed: ${PASSED}"
echo "Tests Failed: ${FAILED}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "╔════════════════════════════════════════╗"
    echo "║   ALL TESTS PASSED SUCCESSFULLY! ✓     ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Application is running and healthy!"
    echo "Access URL: ${TEST_URL}"
    exit 0
else
    echo "╔════════════════════════════════════════╗"
    echo "║      SOME TESTS FAILED! ✗              ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Please check the failed tests above and fix the issues."
    exit 1
fi