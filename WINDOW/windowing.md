# Windowing functions in T-SQL

### references and related materials

- 'Microsoft SQL Server 2012 High performance T-SQL Using Window Functions'. Author: Itzek Ben-Gan. Published: SolidQ. ISBN: 978-0-7356-5836-3

---

# supporting information

T-SQL is a language that is built on a series of frameworks. It is used specifically to work with the SQL Server software solutions. T-SQL is built with:

- Structured Query language
- Set theory
- Relational Algebra

As we move into the specifics of T-SQL, you will begin to find differences between the workings of this language and the workings of other languages, such as those supporting MySQL, PostGRE, etc. Optimizations that we discuss may not apply in other software solutions.

## Set Theory

If you have been trained as a procedural programmer, this will not be intuitive to you. This is an alternative to iterative thinking; In set theory operations are performed on an entire *set* of data at once. In procedural programming, we are able to assume that an operation moves from a piece of data to the next in a known order; In set theory, we see performance boosts due to parallel processing, but we are unable to assume the order at which the operation moves between data points.

## Relational Algebra

Relational Algebra is a mathematical model that describes the relationships between normalized entities. Similar to how PEMDAS allows us to logically evaluate mathematical algebra, **Logical Query Processing** allows us to logically evaluate relational expressions and commands. It follows this order in query processing:

1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
  - evaluate
  - remove duplicates
6. ORDER BY
7. OFFSET-FETCH/TOP

It is important to note that in order to conform to set theory, *only SELECT and ORDER BY clauses of a query can contain a window function.* This is because the where clause can have an effect on the windows chosen, and would give rise to ambiguous results based on ordering that is irrelevant to set theory.

For example:

`SELECT Col1 FROM T1 WHERE Col1 > 'B' AND ROW_NUMBER() OVER(ORDER BY Col1) <= 3;``

and

`SELECT Col1 FROM T1 WHERE ROW_NUMBER() OVER(ORDER BY Col1) <= 3 AND Col1 > 'B';`

These could return different results based on the order that the WHERE clause operates, which is ambiguous in set theory.

---

# Basic Window Function syntax

## clauses

**OVER** A window function is an operation applied to a set of rows. A *Window* is the set of rows over which to apply the operation. The OVER clause allows you to define your window.

**Functions** Currently, Window functions allow the following types of operations:
- Aggregate: COUNT, MIN, MAX, SUM, Etc
- Ranking: RANK, DENSE_RANK, ROW_NUMBER, NTILE
- Distribution: PERCENT_RANK, CUME_DIST, PERCENTILE_COUNT, PERCENTILE_DISC
- Offset: LAG, LEAD, FIRST_VALUE, NTH_VALUE

## example:

`SELECT [orderid], [orderd date], [val], RANK() OVER(ORDER BY [val] DESC) as [rank] FROM [tblORDER] ORDER BY [rank]`

In this example, `RANK` is our operation, and our window is defined by `ORDER BY val DESC`. This is the returned result:

| orderid | orderdate | val | rank |
| - | - | - | - |
| 242434 | 01012012 | 6525.1 | 1 |
| 710413 | 24012012 | 6520.8 | 2 |
| 158621 | 12082013 | 4802.4 | 3 |
---
# Simple solutions

## A replacement for subquery processing

Consider the following query that we wrote as extra credit earlier this quarter:



## The islands problem

---
