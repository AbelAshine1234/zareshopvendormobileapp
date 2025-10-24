#!/bin/bash

# Wallet Management Test Runner
# This script runs all wallet management related tests

echo "🧪 ============================================"
echo "   WALLET MANAGEMENT TEST SUITE"
echo "============================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Installing test dependencies...${NC}"
flutter pub get
echo ""

# Run specific test suites
echo -e "${YELLOW}🧪 Running Tests...${NC}"
echo ""

# 1. Socket Event Tests
echo -e "${BLUE}1️⃣  Testing Socket Events (CashoutRequestEvent, WalletFunds)...${NC}"
flutter test test/core/models/socket_event_test.dart --reporter expanded
SOCKET_EXIT_CODE=$?
echo ""

# 2. Cashout Request Model Tests
echo -e "${BLUE}2️⃣  Testing CashoutRequest Model...${NC}"
flutter test test/features/wallet_management/models/cashout_request_test.dart --reporter expanded
MODEL_EXIT_CODE=$?
echo ""

# 3. Wallet Bloc Tests
echo -e "${BLUE}3️⃣  Testing WalletBloc (Events, States, WebSocket Integration)...${NC}"
flutter test test/features/wallet_management/bloc/wallet_bloc_test.dart --reporter expanded
BLOC_EXIT_CODE=$?
echo ""

# 4. Widget Tests
echo -e "${BLUE}4️⃣  Testing WalletManagementScreen Widget...${NC}"
flutter test test/features/wallet_management/widgets/wallet_management_screen_test.dart --reporter expanded
WIDGET_EXIT_CODE=$?
echo ""

# Summary
echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}   TEST SUMMARY${NC}"
echo -e "${YELLOW}============================================${NC}"

if [ $SOCKET_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Socket Event Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Socket Event Tests: FAILED${NC}"
fi

if [ $MODEL_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Model Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Model Tests: FAILED${NC}"
fi

if [ $BLOC_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Bloc Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Bloc Tests: FAILED${NC}"
fi

if [ $WIDGET_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Widget Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Widget Tests: FAILED${NC}"
fi

echo ""

# Overall result
TOTAL_FAILURES=$((SOCKET_EXIT_CODE + MODEL_EXIT_CODE + BLOC_EXIT_CODE + WIDGET_EXIT_CODE))

if [ $TOTAL_FAILURES -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
fi
