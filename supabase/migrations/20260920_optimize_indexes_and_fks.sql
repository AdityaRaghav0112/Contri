-- ============================================================================
-- Contri App: Database Performance & Indexing Optimization (Solution 4)
-- ============================================================================
-- This script creates performance indexes on foreign keys and commonly filtered/
-- sorted columns to eliminate sequential scans during deep embedded queries.
-- Execute this script in your Supabase SQL Editor.
-- ============================================================================

-- 1. GROUPS TABLE INDEXES
CREATE INDEX IF NOT EXISTS idx_groups_created_by ON groups(created_by);
CREATE INDEX IF NOT EXISTS idx_groups_created_at ON groups(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_groups_status ON groups(status);

-- 2. GROUP_MEMBERS TABLE INDEXES
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_group_members_group_user ON group_members(group_id, user_id);
CREATE INDEX IF NOT EXISTS idx_group_members_joined_at ON group_members(joined_at DESC);

-- 3. EXPENSES TABLE INDEXES
CREATE INDEX IF NOT EXISTS idx_expenses_group_id ON expenses(group_id);
CREATE INDEX IF NOT EXISTS idx_expenses_paid_by ON expenses(paid_by);
CREATE INDEX IF NOT EXISTS idx_expenses_created_by ON expenses(created_by);
CREATE INDEX IF NOT EXISTS idx_expenses_expense_date ON expenses(expense_date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_group_date ON expenses(group_id, expense_date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);

-- 4. EXPENSE_PARTICIPANTS TABLE INDEXES
CREATE INDEX IF NOT EXISTS idx_expense_participants_expense_id ON expense_participants(expense_id);
CREATE INDEX IF NOT EXISTS idx_expense_participants_user_id ON expense_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_expense_participants_expense_user ON expense_participants(expense_id, user_id);

-- 5. SETTLEMENTS TABLE INDEXES
CREATE INDEX IF NOT EXISTS idx_settlements_group_id ON settlements(group_id);
CREATE INDEX IF NOT EXISTS idx_settlements_from_user ON settlements(from_user);
CREATE INDEX IF NOT EXISTS idx_settlements_to_user ON settlements(to_user);
CREATE INDEX IF NOT EXISTS idx_settlements_created_at ON settlements(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_settlements_group_created ON settlements(group_id, created_at DESC);

-- 6. PROFILES TABLE INDEXES
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON profiles(created_at DESC);

-- ============================================================================
-- ANALYZE TABLES TO UPDATE QUERY PLANNER STATISTICS
-- ============================================================================
ANALYZE profiles;
ANALYZE groups;
ANALYZE group_members;
ANALYZE expenses;
ANALYZE expense_participants;
ANALYZE settlements;
