#!/bin/bash

###############################################
# Test Script for Abode Software Application
# Tests container health and application status
###############################################

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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
if command -v docker &> /dev/null && docker info &> /dev/null; then
    echo -e "${GREEN}✓ PASSED${NC}: Docker is running"
    ((PASSED++))
else
    echo -e "${RED}✗ FAILED${NC}: Docker is not running"
    ((FAILED++))
    exit 1
fi
echo ""

###############################################
# Test 2: Check if container exists and is running
###############################################
echo "Test 2: Checking if container is running..."
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo -e "${GREEN}✓ PASSED${NC}: Container '${CONTAINER_NAME}' is running"
    ((PASSED++))
    
    # Get container details
    CONTAINER_ID=$(docker ps -q -f name=${CONTAINER_NAME})
    echo "   Container ID: ${CONTAINER_ID}"
    
    # Check container uptime
    UPTIME=$(docker inspect -f '{{.State.StartedAt}}' ${CONTAINER_NAME})
    echo "   Started at: ${UPTIME}"
else
    echo -e "${RED}✗ FAILED${NC}: Container '${CONTAINER_NAME}' is not running"
    ((FAILED++))
    
    # Check if container exists but is stopped
    if [ "$(docker ps -a -q -f name=${CONTAINER_NAME})" ]; then
        echo "   Container exists but is stopped"
        echo "   Checking logs:"
        docker logs --tail 20 ${CONTAINER_NAME}
    fi
    exit 1
fi
echo ""

###############################################
# Test 3: Check container health
###############################################
echo "Test 3: Checking container health status..."
HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' ${CONTAINER_NAME} 2>/dev/null)

if [ -n "$HEALTH_STATUS" ]; then
    if [ "$HEALTH_STATUS" = "healthy" ]; then
        echo -e "${GREEN}✓ PASSED${NC}: Container health status is healthy"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ WARNING${NC}: Container health status is ${HEALTH_STATUS}"
        echo "   Note: Container is running but health check indicates: ${HEALTH_STATUS}"
    fi
else
    echo -e "${YELLOW}⚠ INFO${NC}: No health check configured for this container"
fi
echo ""

###############################################
# Test 4: Check if application port is accessible
###############################################
echo "Test 4: Checking if application port is accessible..."
if curl -s --max-time 5 ${TEST_URL} > /dev/null; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 ${TEST_URL})
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ PASSED${NC}: Application is accessible (HTTP ${HTTP_CODE})"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠ WARNING${NC}: Application returned HTTP ${HTTP_CODE}"
        echo "   Expected: 200, Got: ${HTTP_CODE}"
    fi
else
    echo -e "${RED}✗ FAILED${NC}: Application is not accessible"
    ((FAILED++))
    echo "   URL: ${TEST_URL}"
    echo "   Check if the port is correctly mapped and firewall is not blocking"
fi
echo ""

###############################################
# Test 5: Check for errors in container logs
###############################################
echo "Test 5: Checking container logs for errors..."
ERROR_COUNT=$(docker logs ${CONTAINER_NAME} 2>&1 | grep -i "error\|fatal\|critical" | wc -l)

if [ "$ERROR_COUNT" -eq 0 ]; then
    echo -e "${GREEN}✓ PASSED${NC}: No errors found in container logs"
    ((PASSED++))
else
    echo -e "${YELLOW}⚠ WARNING${NC}: Found ${ERROR_COUNT} error(s) in container logs"
    echo "   Recent errors:"
    docker logs ${CONTAINER_NAME} 2>&1 | grep -i "error\|fatal\|critical" | tail -5
fi
echo ""

###############################################
# Test 6: Check if required files exist in container
###############################################
echo "Test 6: Checking if application files exist..."
if docker exec ${CONTAINER_NAME} test -d /var/www/html; then
    FILE_COUNT=$(docker exec ${CONTAINER_NAME} ls -A /var/www/html | wc -l)
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}: Application directory exists with ${FILE_COUNT} files"
        ((PASSED++))
        echo "   Directory: /var/www/html"
    else
        echo -e "${RED}✗ FAILED${NC}: Application directory is empty"
        ((FAILED++))
    fi
else
    echo -e "${RED}✗ FAILED${NC}: Application directory does not exist"
    ((FAILED++))
fi
echo ""

###############################################
# Test 7: Check resource usage
###############################################
echo "Test 7: Checking container resource usage..."
CPU_USAGE=$(docker stats ${CONTAINER_NAME} --no-stream --format "{{.CPUPerc}}" | sed 's/%//')
MEM_USAGE=$(docker stats ${CONTAINER_NAME} --no-stream --format "{{.MemPerc}}" | sed 's/%//')

echo "   CPU Usage: ${CPU_USAGE}%"
echo "   Memory Usage: ${MEM_USAGE}%"

# Check if CPU usage is reasonable (less than 80%)
if (( $(echo "$CPU_USAGE < 80" | bc -l) )); then
    echo -e "${GREEN}✓ INFO${NC}: CPU usage is within normal range"
else
    echo -e "${YELLOW}⚠ WARNING${NC}: High CPU usage detected"
fi

# Check if Memory usage is reasonable (less than 80%)
if (( $(echo "$MEM_USAGE < 80" | bc -l) )); then
    echo -e "${GREEN}✓ INFO${NC}: Memory usage is within normal range"
else
    echo -e "${YELLOW}⚠ WARNING${NC}: High memory usage detected"
fi
echo ""

###############################################
# Test Summary
###############################################
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Tests Passed: ${GREEN}${PASSED}${NC}"
echo -e "Tests Failed: ${RED}${FAILED}${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ALL TESTS PASSED SUCCESSFULLY! ✓     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Application is running and healthy!"
    echo "Access URL: ${TEST_URL}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║      SOME TESTS FAILED! ✗              ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please check the failed tests above and fix the issues."
    exit 1
fi
