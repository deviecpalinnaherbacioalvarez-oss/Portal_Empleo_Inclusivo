package com.incluyelab.servlet;

import java.sql.SQLException;

final class SqlBusinessErrors {
    private SqlBusinessErrors() { }

    static boolean isBusinessRule(SQLException exception) {
        for (SQLException current = exception; current != null; current = current.getNextException()) {
            if ("45000".equals(current.getSQLState())) return true;
        }
        return false;
    }

    static String message(SQLException exception, String fallback) {
        for (SQLException current = exception; current != null; current = current.getNextException()) {
            if ("45000".equals(current.getSQLState())) {
                String message = current.getMessage();
                if (message != null && !message.trim().isEmpty()) return message.trim();
            }
        }
        return fallback;
    }
}
