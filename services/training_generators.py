import random


def inflation_loss():
    """
    Генерирует задачу на потерю покупательной способности из-за инфляции.
    :return: dict, текст задания и ответ
    """
    amount = random.randrange(50000, 500001, 10000)
    inflation = random.randint(4, 15)
    answer = amount * (100 - inflation) // 100

    return {
        "text": (
            f"У вас есть {amount} рублей. Инфляция за год составила {inflation}%. "
            "Какова приблизительная покупательная способность этих денег через год?"
        ),
        "answer": str(answer),
    }


def stock_profit():
    """
    Генерирует задачу на расчет прибыли по акции в рублях.
    :return: dict, текст задания и ответ
    """
    buy_price = random.randint(50, 500)
    growth = random.randint(5, 100)
    sell_price = round(buy_price * (100 + growth) / 100)
    sell_price = max(sell_price, buy_price + 1)
    answer = sell_price - buy_price

    return {
        "text": (
            f"Инвестор купил акцию за {buy_price} руб. и продал за {sell_price} руб. "
            "Какую прибыль он получил с одной акции?"
        ),
        "answer": str(answer),
    }


def stock_return_percent():
    """
    Генерирует задачу на расчет доходности акции в процентах.
    :return: dict, текст задания и ответ
    """
    buy_price = random.randrange(100, 1001, 10)
    growth = random.randint(10, 80)
    sell_price = round(buy_price * (100 + growth) / 100)
    answer = round((sell_price - buy_price) / buy_price * 100)

    return {
        "text": (
            f"Акция выросла с {buy_price} до {sell_price} рублей. "
            "Какова доходность инвестиции в процентах?"
        ),
        "answer": str(answer),
    }


def dividend_income():
    """
    Генерирует задачу на расчет дивидендного дохода.
    :return: dict, текст задания и ответ
    """
    shares = random.randint(10, 200)
    dividend = random.randint(2, 50)
    answer = shares * dividend

    return {
        "text": (
            f"Инвестор владеет {shares} акциями. Компания выплатила дивиденды "
            f"{dividend} руб. на акцию. Сколько рублей получит инвестор?"
        ),
        "answer": str(answer),
    }


def bond_coupon_income():
    """
    Генерирует задачу на расчет купонного дохода по облигациям.
    :return: dict, текст задания и ответ
    """
    nominal = random.randrange(1000, 100001, 1000)
    rate = random.randint(5, 15)
    count = random.randint(1, 20)
    answer = count * nominal * rate // 100

    return {
        "text": (
            f"Инвестор владеет {count} облигациями номиналом {nominal} руб. "
            f"с купоном {rate}% годовых. Какой купонный доход он получит за год?"
        ),
        "answer": str(answer),
    }


def bond_redemption():
    """
    Генерирует задачу на расчет суммы погашения облигаций.
    :return: dict, текст задания и ответ
    """
    count = random.randint(1, 30)
    nominal = random.randrange(1000, 10001, 1000)
    answer = count * nominal

    return {
        "text": (
            f"Инвестор держит {count} облигаций номиналом {nominal} руб. "
            "Какую сумму он получит при погашении без учета купонов?"
        ),
        "answer": str(answer),
    }


def management_fee():
    """
    Генерирует задачу на расчет комиссии управления ETF.
    :return: dict, текст задания и ответ
    """
    amount = random.randrange(50000, 1000001, 10000)
    fee = random.randint(2, 20) / 10
    answer = round(amount * fee / 100)

    return {
        "text": (
            f"Инвестор вложил {amount} рублей в ETF с комиссией {fee:g}%. "
            "Сколько рублей составит комиссия за год?"
        ),
        "answer": str(answer),
    }


def futures_profit():
    """
    Генерирует задачу на расчет прибыли или убытка по фьючерсу.
    :return: dict, текст задания и ответ
    """
    buy = random.randrange(1000, 20001, 100)
    change = random.choice([-1, 1]) * random.randint(5, 20)
    sell = round(buy * (100 + change) / 100)
    size = random.randint(1, 10)
    answer = (sell - buy) * size

    return {
        "text": (
            f"Инвестор купил фьючерс по цене {buy}. Позже цена стала {sell}. "
            f"Размер контракта - {size}. Какую прибыль или убыток получил инвестор?"
        ),
        "answer": str(answer),
    }


def margin_calculation():
    """
    Генерирует задачу на расчет гарантийного обеспечения.
    :return: dict, текст задания и ответ
    """
    contract = random.randrange(50000, 2000001, 10000)
    margin = random.randint(5, 20)
    answer = contract * margin // 100

    return {
        "text": (
            f"Стоимость фьючерсного контракта составляет {contract} руб., "
            f"а гарантийное обеспечение - {margin}%. "
            "Сколько рублей необходимо внести для открытия позиции?"
        ),
        "answer": str(answer),
    }


TRAINING_GENERATORS = {
    "inflation_loss": inflation_loss,
    "stock_profit": stock_profit,
    "stock_return_percent": stock_return_percent,
    "dividend_income": dividend_income,
    "bond_coupon_income": bond_coupon_income,
    "bond_redemption": bond_redemption,
    "management_fee": management_fee,
    "futures_profit": futures_profit,
    "margin_calculation": margin_calculation,
}


def generate_training_task(function_name, template, context):
    """
    Вызывает генератор тренировочного задания по имени функции.
    :param function_name: str, имя генератора
    :param template: str, шаблон задания
    :param context: dict, контекст урока
    :return: dict, текст задания и ответ
    """
    generator = TRAINING_GENERATORS.get(function_name)

    if generator is None:
        return {
            "text": template or f"Не найден генератор тренажера: {function_name}",
            "answer": "",
        }

    return generator()
