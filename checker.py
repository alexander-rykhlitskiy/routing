"""
Usage:
    with open("input.txt", "r") as stream:
        problem = Problem.load(stream)
    with open("output.txt", "r") as stream:
        solution = Solution.load(problem, stream)
    cost = solution.validate()  # must not raise ValidationError
"""

import collections
import math
import sys


class LineReader(object):

    def __init__(self, stream):
        self.stream = stream
        self.index = 0

    def read(self):
        result = self.stream.readline()
        if not result:
            raise EOFError()
        self.index += 1
        return result.rstrip()


class ParsingError(Exception):

    def __init__(self, line, error):
        Exception.__init__(self, "error at line %d: %r" % (line, error))


class Problem(object):

    Town = collections.namedtuple("Town", ["x", "y"])
    Parcel = collections.namedtuple("Parcel", ["size", "destination"])
    Case = collections.namedtuple("Case", ["towns", "parcels", "capacity"])

    def __init__(self, cases):
        self.cases = cases

    def __repr__(self):
        return repr(self.cases)

    @classmethod
    def load(cls, stream):
        """
        Args:
            stream (IO) - an open file

        Raises:
            ParsingError if parsing failed
        """

        def parse(reader):
            case_count = int(reader.read())
            cases = [parse_case(reader) for _ in range(case_count)]
            return Problem(cases)

        def parse_case(reader):
            town_count, capacity, parcel_count = map(int, reader.read().split(" ", 2))
            towns = [parse_town(reader) for _ in range(town_count)]
            parcels = [parse_parcel(reader) for _ in range(parcel_count)]
            return Problem.Case(towns, parcels, capacity)

        def parse_town(reader):
            x, y = map(int, reader.read().split(" ", 1))
            return Problem.Town(x, y)

        def parse_parcel(reader):
            size, destination = map(int, reader.read().split(" ", 1))
            return Problem.Parcel(size, destination)

        reader = LineReader(stream)
        try:
            return parse(reader)
        except Exception as error:
            raise ParsingError(reader.index, error)


class ValidationError(Exception):

    def __init__(self, cid, message):
        Exception.__init__(self, "case #%d: %s" % (cid + 1, message))


class Solution(object):

    Route = collections.namedtuple("Route", ["cost", "cycles"])

    def __init__(self, problem, routes):
        self.problem = problem
        self.routes = routes

    def __repr__(self):
        return repr((self.problem, self.routes))

    @classmethod
    def load(cls, problem, stream):
        """
        Args:
            problem (Problem) - a problem definition
            stream (IO) - an open file

        Raises:
            ParsingError if parsing failed
        """

        def parse(reader):
            routes = [parse_route(reader, case) for case in problem.cases]
            return Solution(problem, routes)

        def parse_route(reader, case):
            cost = float(reader.read())
            cycle_count = int(reader.read())
            cycles = [parse_cycle(reader, case) for _ in range(cycle_count)]
            return Solution.Route(cost, cycles)

        def parse_cycle(reader, case):
            data = list(map(int, reader.read().split(" ")))
            assert data[0] == len(data) - 1, "incorrect cycle length"
            result = data[1:]
            assert all(1 <= pid <= len(case.parcels) for pid in result), "invalid parcel ID"
            return result

        reader = LineReader(stream)
        try:
            return parse(reader)
        except Exception as error:
            raise ParsingError(reader.index, error)

    def validate(self):
        """
        Returns:
            Real - the computed total cost

        Raises:
            ValidationError if something is wrong
        """
        cost = 0.0
        origin = Problem.Town(0, 0)
        for cid, (case, route) in enumerate(zip(self.problem.cases, self.routes)):
            case_cost = 0.0
            delivered = set()
            for cycle in route.cycles:
                if sum(case.parcels[pid-1].size for pid in cycle) > case.capacity:
                    raise ValidationError(cid, "capacity exceeded")
                current_town = origin
                for pid in cycle:
                    next_town = case.towns[case.parcels[pid-1].destination-1]
                    case_cost += gap(current_town, next_town)
                    current_town = next_town
                case_cost += gap(current_town, origin)
                delivered |= set(cycle)
            if abs(case_cost - route.cost) > 1e-6:
                raise ValidationError(cid, "incorrect cost: should be %.6f" % case_cost)
            if len(delivered) != len(case.parcels):
                raise ValidationError(cid, "not all parcels have been delivered")
            cost += case_cost
        return cost


def gap(a, b):
    """
    Compute the euclidean distance between two towns.

    Args:
        a (Problem.Town)
        b (Problem.Town)

    Returns:
        Real
    """
    return math.hypot(a.x - b.x, a.y - b.y)


if __name__ == "__main__":
    with open(sys.argv[1], "r") as stream:
        problem = Problem.load(stream)
    with open(sys.argv[2], "r") as stream:
        solution = Solution.load(problem, stream)
    print(solution.validate())
